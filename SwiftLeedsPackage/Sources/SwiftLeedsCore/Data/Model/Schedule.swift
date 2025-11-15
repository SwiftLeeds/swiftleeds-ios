//
//  Schedule.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 01/08/2022.
//

import Foundation

public struct Schedule: Codable {
    public let data: Data
    
    public struct Data: Codable {
        public let event: Event
        public let events: [Event]
        public let days: [Day]
    }

    public struct Day: Codable, Identifiable {
        public let date: Date
        public let name: String
        public let slots: [Slot]
        public var id: String {
            "\(name)-\(date.timeIntervalSince1970.description)"
        }
    }

    public struct Event: Codable, Identifiable {
        public let id: UUID
        public let name: String
        public let location: String
        public let date: Date

        public var daysUntil: Int {
            Calendar.current.numberOfDays(to: date)
        }
    }

    public struct Slot: Identifiable {
        public let id: UUID
        public let date: Date?
        public let startTime: String
        public let duration: Int
        public let activity: Activity?
        public let presentation: Presentation?
        
        public init(
            id: UUID,
            date: Date?,
            startTime: String,
            duration: Int,
            activity: Activity?,
            presentation: Presentation?
        ) {
            self.id = id
            self.date = date
            self.startTime = startTime
            self.duration = duration
            self.activity = activity
            self.presentation = presentation
        }
        
        private enum CodingKeys: CodingKey {
            case id, activity, presentation, date, startTime, duration
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
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        id = try values.decode(UUID.self, forKey: .id)
        startTime = try values.decode(String.self, forKey: .startTime)
        duration = try values.decode(Int.self, forKey: .duration)

        let date = try values.decodeIfPresent(String.self, forKey: .date) ?? ""
        self.date = ISO8601DateFormatter().date(from: date)

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
    public static func == (lhs: Schedule.Slot, rhs: Schedule.Slot) -> Bool {
        lhs.id == rhs.id
    }
}
