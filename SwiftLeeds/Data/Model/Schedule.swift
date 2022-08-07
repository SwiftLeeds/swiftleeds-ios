//
//  Schedule.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 01/08/2022.
//

import Foundation

struct Schedule: Decodable {
    let data: Data

    struct Data: Decodable {
        let event: Event
        let slots: [Slot]
    }

    struct Event: Decodable {
        let id: UUID
        let name: String
        let location: String
        let date: Date
    }

    struct Slot: Identifiable {
        let id: UUID
        let startTime: String
        let duration: Int
        let activity: Activity?
        let presentation: Presentation?

        private enum CodingKeys: CodingKey {
            case id, activity, presentation, startTime, duration
        }

        static var timeFormat: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter
        }()
    }
}

// MARK: - Slot Decodable
extension Schedule.Slot: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        id = try values.decode(UUID.self, forKey: .id)
        duration = try values.decode(Int.self, forKey: .duration)
        startTime = try values.decode(String.self, forKey: .startTime)

        if let activity = try values.decodeIfPresent(Activity.self, forKey: .activity) {
            self.activity = activity
            self.presentation = nil
        } else if let presentation = try values.decodeIfPresent(Presentation.self, forKey: .presentation) {
            self.activity = nil
            self.presentation = presentation
        } else {
            throw(SlotError.invalidSlot)
        }
    }

    enum SlotError: Error {
        case invalidSlot
    }
}

// MARK: - Slot Equatable
extension Schedule.Slot: Equatable {
    static func == (lhs: Schedule.Slot, rhs: Schedule.Slot) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Activity
struct Activity: Decodable, Identifiable {
    let id: UUID
    let title: String
    let subtitle: String?
    let description: String?
    let image: String?
    let metadataURL: String?

    static let lunch = Activity(id: UUID(), title: "Lunch 🍕", subtitle: "It's time for some well deserved food", description: "We have partnered with the venue to provide us with handmade food. The venue has an incredible chef who will produce food to cater to everyone. They have access to a stone-baked pizza oven to provide fresh pizza slices and handmade buffet food with a vast selection. Don't forget your handmade brownie or Bakewell slice 😋", image: "IMG_6298.jpg-93D1F0E2-6F47-4149-944B-FB824EFB2549", metadataURL: "")
}

// MARK: - Presentation
struct Presentation: Decodable, Identifiable {
    let id: UUID
    let title: String
    let synopsis: String
    let speaker: Speaker?
    let image: String?

    static let donnyWalls = Presentation(id: UUID(), title: "Building (and testing) custom property wrappers for SwiftUI", synopsis: "In this talk, you will learn everything you need to know about using DynamicProperty to build custom property wrappers that integrate with SwiftUI’s view lifecycle and environment beautifully. And more importantly, you will learn how you can write unit tests for your custom property wrappers as well.", speaker: .init(id: UUID(), name: "Donny Wals", biography: "I'm a curious, passionate iOS Developer from The Netherlands who loves learning and sharing knowledge.", profileImage: "jOaeQ1Og_400x400.jpeg-AEAB9C2A-9572-4E6A-A63E-C3534EE5C321", organisation: "DonnyWals.com", twitter: "donnywals"), image: nil)
}

// MARK: - Speaker
struct Speaker: Decodable, Identifiable {
    let id: UUID
    let name: String
    let biography: String
    let profileImage: String
    let organisation: String
    let twitter: String?
}
