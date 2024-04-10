//
//  EditTalkFeatureTests.swift
//  TalkingHeadsRevisitedTests
//
//  Created by Markus Müller on 11.04.24.
//

import XCTest
@testable import TalkingHeadsRevisited
import ComposableArchitecture

final class EditTalkFeatureTests: XCTestCase {
    @MainActor
    func testEditingATalk() async throws {
        let store = TestStore(initialState: EditTalk.State(talk: .tcaRevisited)) {
            EditTalk()
        } withDependencies: {
            $0.dismiss = .init({} )
        }

        await store.send(\.binding.talk, Talk.cppGUIDevelopment) {
            $0.talk = .cppGUIDevelopment
        }

        await store.send(.removeButtonTapped) {
            $0.destination = .removeTalk(.cppGUIDevelopment)
        }

        await store.send(\.destination.cancel) {
            $0.destination = nil
        }

        await store.send(.removeButtonTapped) {
            $0.destination = .removeTalk(.cppGUIDevelopment)
        }

        await store.send(\.destination.confirm) {
            $0.destination = nil
        }

        await store.receive(\.delegate.removeTalkConfirmed, Talk.cppGUIDevelopment.id)
    }
}
