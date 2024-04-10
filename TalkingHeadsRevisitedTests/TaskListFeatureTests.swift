//
//  TaskListFeatureTests.swift
//  TalkingHeadsRevisitedTests
//
//  Created by Markus Müller on 11.04.24.
//

import XCTest
@testable import TalkingHeadsRevisited
import ComposableArchitecture

final class TaskListFeatureTests: XCTestCase {
    @MainActor
    func testLoadingFromTalkClient() async throws {
        let (stream, cont) = AsyncStream.makeStream(of: [Talk].self)
        let store = TestStore(initialState: TalkList.State()) {
            TalkList()
        } withDependencies: {
            $0.talkClient.talksStream = { stream }
        }

        let task = await store.send(.task)

        cont.yield([.cppGUIDevelopment, .frameworkOfTheWeek])

        await store.receive(\.talksUpdated) {
            $0.talks = [EditTalk.State(talk: .cppGUIDevelopment), .init(talk: .frameworkOfTheWeek)]
            $0.isLoading = false
        }

        await task.cancel()
    }

    @MainActor
    func testRemovingTalks() async throws {
        let store = TestStore(initialState: TalkList.State(talks: [.init(talk: .legacyTCA), .init(talk: .tcaRevisited), .init(talk: .testing)])) {
            TalkList()
        }

        await store.send(.clearButtonTapped) {
            $0.talks = []
        }
    }

    @MainActor
    func testSuccessfulSaveOnClient() async throws {
        let saveSpy = LockIsolated<[Talk]>([])
        let store = TestStore(initialState: TalkList.State(talks: [.init(talk: .jsonParsing), .init(talk: .enterpriseSwift), .init(talk: .cppGUIDevelopment)])) {
            TalkList()
        } withDependencies: {
            $0.talkClient.save = { saveSpy.setValue($0) }
        }

        await store.send(.saveButtonTapped)

        XCTAssertNoDifference([.jsonParsing, .enterpriseSwift, .cppGUIDevelopment], saveSpy.value)
    }

    @MainActor
    func testFailingSaveOnClient() async throws {
        struct TestError: LocalizedError {
            var errorDescription: String? = "Test Error"
        }

        let store = TestStore(initialState: TalkList.State(talks: [.init(talk: .jsonParsing)])) {
            TalkList()
        } withDependencies: {
            $0.talkClient.save = { _ in throw TestError() }
        }

        await store.send(.saveButtonTapped)

        await store.receive(\.failureMessage) {
            $0.isLoading = false
            $0.destination = .alert(.failure(message: "Test Error"))
        }
    }

    @MainActor
    func testAddingATalk() async throws {
        let store = TestStore(initialState: TalkList.State()) {
            TalkList()
        } withDependencies: {
            $0.uuid = .incrementing
        }

        await store.send(.addButtonTapped) {
            $0.destination = .add(AddTalk.State(talk: .init(id: .init(0))))
        }

        await store.send(\.destination.add.binding.talk, Talk(id: .init(0), title: "Talk title")) {
            $0.destination.modify(\.add) {
                $0.talk.title = "Talk title"
            }
        }

        await store.send(.destination(.presented(.add(AddTalk.Action.addButtonTapped)))) {
            let talk = try XCTUnwrap($0.destination[case: \.add]?.talk)
            $0.talks.append(.init(talk: talk))
        }

        await store.receive(\.destination.dismiss) {
            $0.destination = nil
        }
    }

}
