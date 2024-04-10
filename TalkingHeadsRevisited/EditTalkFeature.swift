//
//  EditTalkFeature.swift
//  TalkingHeadsRevisited
//
//  Created by Markus Müller on 10.04.24.
//

import Foundation
import ComposableArchitecture
import SwiftUI

@Reducer
struct EditTalk {
    @ObservableState
    struct State: Equatable {
        var talk: Talk
        @Presents
        var destination: ConfirmationDialogState<Action.Confirmation>?
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case doneButtonTapped
        case editButtonTapped
        case removeButtonTapped
        case destination(PresentationAction<Confirmation>)
        case delegate(Delegate)

        @CasePathable
        enum Delegate {
            case removeTalkConfirmed(Talk.ID)
        }

        @CasePathable
        enum Confirmation {
            case confirm
            case cancel
        }
    }

    @Dependency(\.talkClient.fetchSuggested) var fetchSuggested
    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .doneButtonTapped:
                return .run { _ in
                    await dismiss()
                }

            case .removeButtonTapped:
                state.destination = .removeTalk(state.talk)
                return .none

            case .destination(.presented(.confirm)):
                return .run { [id = state.talk.id] send in
                    await send(.delegate(.removeTalkConfirmed(id)))
                    await dismiss()
                }

            case .editButtonTapped:
                return .none

            case .destination:
                return .none

            case .delegate:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension ConfirmationDialogState where Action == EditTalk.Action.Confirmation {
    static func removeTalk(_ talk: Talk) -> Self {
        return ConfirmationDialogState {
            TextState(talk.title)
        } actions: {
            ButtonState(role: .destructive, action: .confirm) {
                TextState("Delete")
            }
            ButtonState(role: .cancel) {
                TextState("Cancel")
            }
        } message: {
            TextState("Are you sure to delete \(talk.title)?")
        }
    }
}

struct EditTalkView: View {
    @Bindable var store: StoreOf<EditTalk>

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

            Section {
                Toggle("Was given", isOn: Binding(get: {
                    store.talk.givenDate != nil
                }, set: {
                    store.talk.givenDate = $0 ? Date.now : nil
                }))

                if let date = store.talk.givenDate {
                    DatePicker("Date", selection: Binding(get: {
                        date
                    }, set: {
                        store.talk.givenDate = $0
                    }), displayedComponents: [.date])
                }
            }

            Button("Remove") {
                store.send(.removeButtonTapped)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .foregroundStyle(.red)
        }
        .confirmationDialog($store.scope(state: \.destination, action: \.destination))
        .navigationTitle("Edit talk")
        .toolbar {
            ToolbarItem {
                Button("Done") { store.send(.doneButtonTapped) }
                    .disabled(store.talk.title.isEmpty)
            }
        }
    }
}

#Preview {
    EditTalkView(
        store: Store(
            initialState: EditTalk.State(
                talk: Talk(
                    title: "TCA revisited",
                    score: 3
                )
            )
        ) {
            EditTalk()
        }
    )
}
