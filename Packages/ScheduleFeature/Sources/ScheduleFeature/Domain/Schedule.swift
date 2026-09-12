import Foundation

public struct Schedule: Codable {
    public let data: Data

    public init(data: Data) {
        self.data = data
    }

    public struct Data: Codable {
        public let event: Event
        public let events: [Event]
        public let days: [Day]

        public init(event: Event, events: [Event], days: [Day]) {
            self.event = event
            self.events = events
            self.days = days
        }
    }

    public struct Day: Codable, Identifiable {
        public let date: Foundation.Date
        public let name: String
        public let slots: [Slot]

        public var id: String {
            "\(name)-\(date.timeIntervalSince1970.description)"
        }

        public init(date: Foundation.Date, name: String, slots: [Slot]) {
            self.date = date
            self.name = name
            self.slots = slots
        }
    }

    public struct Event: Codable, Identifiable {
        public let id: UUID
        public let name: String
        public let location: String
        public let date: Foundation.Date

        public var daysUntil: Int {
            Calendar.current.numberOfDays(to: date)
        }

        public init(id: UUID, name: String, location: String, date: Foundation.Date) {
            self.id = id
            self.name = name
            self.location = location
            self.date = date
        }
    }

    public struct Slot: Identifiable {
        public let id: UUID
        public let date: Foundation.Date?
        public let startTime: String
        public let duration: Int
        public let activity: Activity?
        public let presentation: Presentation?

        private enum CodingKeys: CodingKey {
            case id, activity, presentation, date, startTime, duration
        }

        public init(
            id: UUID,
            date: Foundation.Date?,
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
    }
}

// MARK: - Slot Decodable
extension Schedule.Slot: Codable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        id = try values.decode(UUID.self, forKey: .id)
        startTime = try values.decode(String.self, forKey: .startTime)
        duration = try values.decode(Int.self, forKey: .duration)

        self.date = try values.decodeIfPresent(Foundation.Date.self, forKey: .date)

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

    public enum SlotError: Error {
        case invalidSlot
    }
}

// MARK: - Slot Equatable
extension Schedule.Slot: Equatable {
    public static func == (lhs: Schedule.Slot, rhs: Schedule.Slot) -> Bool {
        lhs.id == rhs.id
    }
}

private extension Calendar {
    func numberOfDays(to date: Date) -> Int {
        let fromDate = startOfDay(for: Date.now)
        let toDate = startOfDay(for: date)
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)

        return numberOfDays.day ?? 0
    }
}
