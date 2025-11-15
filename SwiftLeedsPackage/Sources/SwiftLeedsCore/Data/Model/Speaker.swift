//
//  Speaker.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 31/08/2022.
//

import Foundation

public struct Speaker: Codable, Identifiable {
    public let id: UUID
    public let name: String
    public let biography: String
    public let profileImage: String
    public let organisation: String
    public let twitter: String?
}

// MARK: - Formatting helpers
extension Array where Element == Speaker {
    public var joinedNames: String {
        ListFormatter.localizedString(byJoining: self.map { $0.name })
    }

    public var joinedOrganisations: String {
        let organisations = Set(self.map { $0.organisation })
        return ListFormatter.localizedString(byJoining: organisations.map { $0 })
    }
}
