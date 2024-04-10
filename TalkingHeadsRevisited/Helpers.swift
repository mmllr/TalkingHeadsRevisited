//
//  Helpers.swift
//  TalkingHeadsRevisited
//
//  Created by Markus Müller on 10.04.24.
//

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
