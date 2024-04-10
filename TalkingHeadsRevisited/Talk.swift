//
//  Talk.swift
//  TalkingHeadsRevisited
//
//  Created by Markus Müller on 10.04.24.
//

import Foundation

struct Talk: Identifiable, Codable, Equatable, Sendable {
    init(id: UUID = UUID(), title: String = "", score: Int = 0, givenDate: Date? = nil) {
        self.id = id
        self.title = title
        self.score = score
        self.givenDate = givenDate
    }

    var id: UUID = UUID()

    var title: String
    var score: Int
    var givenDate: Date?
}

extension ClosedRange<Int> {
    static let allowedScores = 1...5
}

extension Talk {
    static let testing: Self = .init(title: "Is testing really dead?", score: Int.random(in: .allowedScores))
    static let enterpriseSwift: Self = .init(title: "Enterprise Swift on the Server", score: Int.random(in: .allowedScores))
    static let jsonParsing: Self = .init(title: "JSON parsing from scratch in C89", score: Int.random(in: .allowedScores))
    static let cppGUIDevelopment: Self = .init(title: "C++ GUI development", score: Int.random(in: .allowedScores))
    static let frameworkOfTheWeek: Self = .init(title: "Framework of the week", score: Int.random(in: .allowedScores))
    static let tcaRevisited: Self = .init(title: "TCA revisited", score: Int.random(in: .allowedScores))
    static let legacyTCA: Self = .init(title: "Legacy TCA", score: Int.random(in: .allowedScores), givenDate: Calendar.current.date(from: DateComponents(year: 2022, month: 5, day: 12)))
}

extension Array<Talk> {
    static let demo: Self = [.testing, .cppGUIDevelopment, .enterpriseSwift, .frameworkOfTheWeek, .jsonParsing, .tcaRevisited, .legacyTCA]
}
