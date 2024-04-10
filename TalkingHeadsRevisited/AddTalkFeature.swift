//
//  AddTalkFeature.swift
//  TalkingHeadsRevisited
//
//  Created by Markus Müller on 11.04.24.
//

import Foundation
import ComposableArchitecture
import SwiftUI

@Reducer
struct AddTalk {
    @ObservableState
    struct State: Equatable, Identifiable {
        var id: Talk.ID { talk.id }
        var talk: Talk
        var isFetching: Bool = false
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case fetchButtonTapped
        case fetchResult(Result<String, Error>)
        case addButtonTapped
    }

    @Dependency(\.talkClient.fetchSuggested) var fetchSuggested
    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .fetchButtonTapped:
                state.isFetching = true
                return .run { send in
                    await send(.fetchResult(Result {
                        try await fetchSuggested()
                    }))
                }
            case let .fetchResult(.success(title)):
                state.talk.title = title
                state.isFetching = false
                return .none

            case .fetchResult(.failure):
                return .none

            case .addButtonTapped:
                return .run { _ in
                    await dismiss()
                }
            }
        }
    }
}


struct AddTalkView: View {
    @Bindable var store: StoreOf<AddTalk>

    var body: some View {
        Form {
            TextField("Title", text: $store.talk.title)

            VStack(alignment: .leading) {
                Stepper(
                    value: $store.talk.score,
                    in: .allowedScores,
                    step: 1
                ) {
                    ScoreView(score: $store.talk.score)
                }
            }
            .disabled(store.isFetching)

            Section {
                HStack {
                    Button("Fetch title from the internet™") {
                        store.send(.fetchButtonTapped)
                    }
                    .disabled(store.isFetching)

                    if store.isFetching {
                        Spacer()
                        ProgressView()
                    }
                }
            }
        }
        .navigationTitle("Add talk")
        .toolbar {
            ToolbarItem {
                Button("Add") { store.send(.addButtonTapped) }
                    .disabled(store.talk.title.isEmpty)
            }
        }
    }
}

#Preview {
    AddTalkView(
        store: Store(
            initialState: AddTalk.State(talk: .init())
        ) {
            AddTalk()
        }
    )
}
