//
//  Activity.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 31/08/2022.
//

import Foundation

// MARK: - Activity
public struct Activity: Codable, Identifiable {
    public let id: UUID
    public let title: String
    public let subtitle: String?
    public let description: String?
    public let image: String?
    public let metadataURL: String?
}

// MARK: - Static Data
extension Activity {
    public static let lunch = Activity(
        id: UUID(),
        title: "Lunch 🍕",
        subtitle: "It's time for some well deserved food",
        description: "We have partnered with the venue to provide us with handmade food. The venue has an incredible chef who will produce food to cater to everyone. They have access to a stone-baked pizza oven to provide fresh pizza slices and handmade buffet food with a vast selection. Don't forget your handmade brownie or Bakewell slice 😋",
        image: "IMG_6298.jpg-93D1F0E2-6F47-4149-944B-FB824EFB2549",
        metadataURL: ""
    )
}
