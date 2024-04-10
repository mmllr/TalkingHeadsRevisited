//
//  TalkRowView.swift
//  TalkingHeadsRevisited
//
//  Created by Markus Müller on 10.04.24.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct TalkRowView: View {
    @Bindable var store: StoreOf<EditTalk>

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(store.talk.title)

            ScoreView(score: $store.talk.score)

            if let date = store.talk.givenDate {
                LabeledContent("Held on", value: date.formatted(date: .complete, time: .omitted))
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .trailing) {
            Button {
                store.send(.editButtonTapped)
            } label: {
                Image(systemName: "info.circle")
            }
        }
    }
}

#Preview {
    List {
        TalkRowView(store: Store(initialState: EditTalk.State(talk: .tcaRevisited)) { EditTalk() })
    }
}
