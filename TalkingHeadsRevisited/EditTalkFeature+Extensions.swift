//
//  EditTalkFeature+Extensions.swift
//  TalkingHeadsRevisited
//
//  Created by Markus Müller on 11.04.24.
//

import Foundation

extension EditTalk.State: Identifiable {
    var id: Talk.ID { talk.id }
}
