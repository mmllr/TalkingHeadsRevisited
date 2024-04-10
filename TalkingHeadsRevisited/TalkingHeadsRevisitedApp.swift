//
//  TalkingHeadsRevisitedApp.swift
//  TalkingHeadsRevisited
//
//  Created by Markus Müller on 10.04.24.
//

import SwiftUI
import ComposableArchitecture

@main
struct TalkingHeadsRevisitedApp: App {
    var body: some Scene {
        WindowGroup {
            TalkListView(store: Store(initialState: TalkList.State()) { TalkList() })
        }
    }
}
