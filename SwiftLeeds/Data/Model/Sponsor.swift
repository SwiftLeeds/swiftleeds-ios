//
//  Sponsor.swift
//  SwiftLeeds
//
//  Created by Muralidharan Kathiresan on 26/06/23.
//

import Foundation

struct Sponsors: Decodable {
    let data: [Sponsor]
}

struct Sponsor: Decodable, Hashable, Identifiable {
    let image: String
    let name: String
    let subtitle: String
    let sponsorLevel: SponsorLevel
    let url: String
    let id: String
}

enum SponsorLevel: String, Decodable {
    case silver
    case platinum
    case gold
}
