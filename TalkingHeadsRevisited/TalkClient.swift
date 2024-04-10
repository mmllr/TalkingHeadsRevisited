//
//  TalkClient.swift
//  TalkingHeadsRevisited
//
//  Created by Markus Müller on 10.04.24.
//

import Combine
import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
struct TalkClient: Sendable {
    var fetchSuggested: @Sendable () async throws -> String
    var talksStream: @Sendable () -> AsyncStream<[Talk]> = { .finished }
    var load: @Sendable () async throws -> Void
    var save: @Sendable ([Talk]) async throws -> Void
}

extension TalkClient {
    static func inMemory(initial: [Talk] = .demo) -> Self {
        let talks: CurrentValueSubject<[Talk], Never> = .init(initial)
        struct ClientError: LocalizedError {
            var errorDescription: String? {
                ["Internet was down", "A:\\DATABASE.TXT not found", "Encoding error"].randomElement()
            }
        }
        return .init(
            fetchSuggested: {
                try await Task.sleep(for: .milliseconds(Int.random(in: 500 ... 1900)))
                return [
                    "Back to basics with 6502 assembly",
                    "Welcome to dependency hell with npm",
                    "Notepad, vi, ed - replacing Xcode",
                    "Reinventing the 🛞 with manual layout",
                    "Forget about architecture 🍝"
                ].randomElement()!
            }, talksStream: {
                talks.values.eraseToStream()
            }, load: {
                try await Task.sleep(for: .milliseconds(Int.random(in: 500 ... 1900)))
                if Bool.random() {
                    talks.send(talks.value)
                } else {
                    throw ClientError()
                }
            }, save: { saved in
                if Bool.random() {
                    talks.value = saved
                } else {
                    throw ClientError()
                }
            }
        )
    }
}

extension TalkClient: TestDependencyKey {
    static var testValue: TalkClient = .init()
    static var previewValue: TalkClient = .inMemory(initial: .demo)
}

extension TalkClient: DependencyKey {
    static var liveValue: TalkClient = .inMemory(initial: .demo)
}

extension DependencyValues {
    var talkClient: TalkClient {
        get { self[TalkClient.self] }
        set { self[TalkClient.self] = newValue }
    }
}
