import Foundation

struct Schedule: Codable {
    let data: Data


    struct Data: Codable {
        let event: Event
        let events: [Event]
        let days: [Day]
    }

    struct Day: Codable, Identifiable {
        let date: Date
        let name: String
        let slots: [Slot]

        var id: String {
            "\(name)-\(date.timeIntervalSince1970.description)"
        }
    }

    struct Event: Codable, Identifiable {
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
        let date: Date?
        let startTime: String
        let duration: Int
        let activity: Activity?
        let presentation: Presentation?

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
    init(from decoder: Decoder) throws {
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
    static func == (lhs: Schedule.Slot, rhs: Schedule.Slot) -> Bool {
        lhs.id == rhs.id
    }
}
