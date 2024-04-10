//
//  TalkListFeature.swift
//  TalkingHeadsRevisited
//
//  Created by Markus Müller on 10.04.24.
//

import Foundation
import ComposableArchitecture
import SwiftUI

@Reducer
struct TalkList {
    @Reducer(state: .equatable)
    enum Destination {
        enum Alert: Equatable {}
        case add(AddTalk)
        case edit(EditTalk)
        case alert(AlertState<Alert>)
    }

    @ObservableState
    struct State: Equatable {
        var talks: IdentifiedArrayOf<EditTalk.State> = []
        var isLoading: Bool = true
        @Presents
        var destination: Destination.State?
    }

    enum Action {
        case task
        case addButtonTapped
        case loadButtonTapped
        case saveButtonTapped
        case clearButtonTapped
        case talksUpdated([Talk])
        case destination(PresentationAction<Destination.Action>)
        case talks(IdentifiedAction<EditTalk.State.ID, EditTalk.Action>)
        case failureMessage(Error)
    }

    @Dependency(\.talkClient) var talkClient
    @Dependency(\.uuid) var uuid

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                return .run { send in
                    for await talks in talkClient.talksStream() {
                        await send(.talksUpdated(talks))
                    }
                }

            case .addButtonTapped:
                state.destination = .add(.init(talk: Talk(id: uuid())))
                return .none

            case .loadButtonTapped:
                state.isLoading = true
                return .run { _ in
                    try await talkClient.load()
                } catch: { error, send in
                    await send(.failureMessage(error))
                }

            case .saveButtonTapped:
                return .run { [talks = state.talks.map(\.talk)] send in
                    do {
                        try await talkClient.save(talks)
                    } catch {
                        await send(.failureMessage(error))
                    }
                }

            case .clearButtonTapped:
                state.talks.removeAll()
                return .none

            case .talksUpdated(let talks):
                state.talks = .init(talks.map { EditTalk.State(talk: $0)}) { $1 }
                state.isLoading = false
                return .none

            case .destination(.presented(.add(.addButtonTapped))):
                guard let talk = state.destination?.add?.talk else { return .none }
                state.talks.updateOrAppend(.init(talk: talk))
                return .none

            case let .talks(.element(id: id, action: .editButtonTapped)):
                guard let editState = state.talks[id: id] else { return .none }
                state.destination = .edit(editState)
                return .none

            case .destination(.presented(.edit(.doneButtonTapped))):
                guard let talkState = state.destination?.edit else { return .none }
                state.talks[id: talkState.id]?.talk = talkState.talk
                return .none

            case .destination(.presented(.edit(.delegate(.removeTalkConfirmed(let id))))):
                state.talks.remove(id: id)
                return .none

            case .failureMessage(let error):
                state.isLoading = false
                state.destination = .alert(.failure(message: error.localizedDescription))
                return .none

            case .talks:
                return .none

            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .forEach(\.talks, action: \.talks) {
            EditTalk()
        }
    }
}

struct TalkListView: View {
    @Bindable var store: StoreOf<TalkList>

    var body: some View {
        NavigationStack {
            List {
                if !store.talks.isEmpty {
                    Section("Prepared talks") {
                        ForEach(store.scope(state: \.talks, action: \.talks).filter { $0.talk.givenDate == nil }) { rowStore in
                            TalkRowView(store: rowStore)
                        }
                    }

                    Section("Given talks") {
                        ForEach(store.scope(state: \.talks, action: \.talks).filter { $0.talk.givenDate != nil }) { rowStore in
                            TalkRowView(store: rowStore)
                        }
                    }
                }
            }
            .overlay {
                if store.talks.isEmpty {
                    ContentUnavailableView {
                        Label("No talks found", systemImage: "questionmark")
                    } description: {
                        Text("Tap on the + in the toolbar to create a talk from a template")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    if store.isLoading {
                        ProgressView()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button { store.send(.addButtonTapped) } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 20) {
                    Button("Load") { store.send(.loadButtonTapped) }
                    Button("Remove all") { store.send(.clearButtonTapped) }
                    Button("Save") { store.send(.saveButtonTapped) }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.bar)

            }
            .task {
                await store.send(.task).finish()
            }
            .sheet(item: $store.scope(state: \.destination?.add, action: \.destination.add)) { store in
                NavigationStack {
                    AddTalkView(store: store)
                }
            }
            .sheet(item: $store.scope(state: \.destination?.edit, action: \.destination.edit)) { store in
                NavigationStack {
                    EditTalkView(store: store)
                        .interactiveDismissDisabled()
                }
            }
            .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
            .navigationTitle("TalkingHeads")
        }
    }
}

extension AlertState where Action == TalkList.Destination.Alert {
    static func failure(message: String) -> Self {
        AlertState {
            TextState("An error occurred")
        } message: {
            TextState(message)
        }
    }
}

#Preview {
    TalkListView(store: Store(initialState: TalkList.State()) { TalkList()} )
}
