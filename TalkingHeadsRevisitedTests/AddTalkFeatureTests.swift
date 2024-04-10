//
//  AddTalkFeatureTests.swift
//  TalkingHeadsRevisitedTests
//
//  Created by Markus Müller on 11.04.24.
//

import XCTest
@testable import TalkingHeadsRevisited
import ComposableArchitecture

final class AddTalkFeatureTests: XCTestCase {

    @MainActor
    func testBindings() async throws {
        let store = TestStore(initialState: AddTalk.State(talk: .init())) {
            AddTalk()
        }

        let updated = Talk(title: "Edited title", score: 4)
        await store.send(\.binding.talk, updated) {
            $0.talk = updated
        }
    }

    @MainActor
    func testFetching() async throws {
        let store = TestStore(initialState: AddTalk.State(talk: .init())) {
            AddTalk()
        } withDependencies: {
            $0.talkClient.fetchSuggested = { "Test title" }
        }

        await store.send(.fetchButtonTapped) {
            $0.isFetching = true
        }

        await store.receive(\.fetchResult.success) {
            $0.talk.title = "Test title"
            $0.isFetching = false
        }
    }

}
