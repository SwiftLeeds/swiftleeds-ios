//
//  Speaker.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 31/08/2022.
//

import Foundation

struct Speaker: Decodable, Identifiable {
    let id: UUID
    let name: String
    let biography: String
    let profileImage: String
    let organisation: String
    let twitter: String?
}

// MARK: - Formatting helpers
extension Array where Element == Speaker {
    var joinedNames: String {
        ListFormatter.localizedString(byJoining: self.map { $0.name })
    }

    var joinedOrganisations: String {
        let organisations = Set(self.map { $0.organisation })
        return ListFormatter.localizedString(byJoining: organisations.map { $0 })
    }
}
