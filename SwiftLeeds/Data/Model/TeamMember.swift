//
//  File.swift
//  SwiftLeeds
//
//  Created by Muralidharan Kathiresan on 09/09/2025.
//

import Foundation

struct TeamMember: Codable, Identifiable {
    let name: String
    let role: String?
    let linkedInURL: String?
    let twitterURL: String?
    let slackURL: String?
    let photoURL: String?
    
    var id: String { name }
}
