//
//  ScoreView.swift
//  TalkingHeadsRevisited
//
//  Created by Markus Müller on 10.04.24.
//

import SwiftUI

struct ScoreView: View {
    @Binding var score: Int

    var body: some View {
        HStack {
            ForEach(1..<6) { idx in
                Image(systemName: idx > score ? "star" : "star.fill")
                    .onTapGesture {
                        score = idx
                    }
            }
        }
    }
}

#Preview {
    ScoreView(score: .constant(Int.random(in: .allowedScores)))
}
