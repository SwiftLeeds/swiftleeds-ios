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

        static let sample = Schedule.Slot(id: UUID(), startTime: "11:00", duration: 30, activity: nil, presentation: .init(id: UUID(), title: "My Title", synopsis: "My synopsis", speaker: .init(id: UUID(), name: "Matthew Gallagher", biography: "Creates apps", profileImage: "", organisation: "PDA Monkey", twitter: "pdamonkey"), image: nil))
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
}

// MARK: - Presentation
struct Presentation: Decodable, Identifiable {
    let id: UUID
    let title: String
    let synopsis: String
    let speaker: Speaker?
    let image: String?
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
