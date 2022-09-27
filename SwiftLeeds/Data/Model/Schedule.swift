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

        var daysUntil: Int {
            Calendar.current.numberOfDays(to: date)
        }
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
extension Schedule.Slot: Codable {
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
