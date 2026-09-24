import Foundation

/// A published schedule for one conference event.
public struct Schedule: Codable, Sendable {
    /// The schedule's contents.
    public let data: Data

    /// Creates a schedule from an already validated payload.
    ///
    /// - Parameter data: The schedule's contents.
    public init(data: Data) {
        self.data = data
    }

    /// Everything one schedule carries.
    ///
    /// Named after the JSON key, which shadows `Foundation.Data`.
    public struct Data: Codable, Sendable {
        /// Why a payload could not become a schedule.
        public enum ParsingError: Error, Equatable {
            /// The payload carried no days.
            ///
            /// An event whose schedule is unpublished arrives this way.
            case noDays
        }

        /// The event this schedule belongs to.
        public let event: Event

        /// The announced events in this conference, oldest first.
        ///
        /// One deployment serves one conference, so a SwiftLeeds build never
        /// sees a KotlinLeeds event. An event dated before 2015 counts as
        /// unannounced and is withheld.
        public let events: [Event]

        /// The event's days, never empty.
        public let days: [Day]

        /// Creates a payload, refusing one that carries no days.
        ///
        /// - Parameters:
        ///   - event: The event this schedule belongs to.
        ///   - events: Every event the backend knows about.
        ///   - days: The event's days. Must not be empty.
        public init(event: Event, events: [Event], days: [Day]) throws(ParsingError) {
            guard days.isEmpty == false else { throw .noDays }

            self.event = event
            self.events = events
            self.days = days
        }

        /// Creates a payload, refusing one that carries no days.
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            try self.init(
                event: container.decode(Event.self, forKey: .event),
                events: container.decode([Event].self, forKey: .events),
                days: container.decode([Day].self, forKey: .days)
            )
        }
    }

    /// One day of an event, with its running order.
    public struct Day: Codable, Identifiable, Sendable {
        /// The calendar day this day covers.
        public let date: Foundation.Date

        /// The organizers' name for the day, such as "Day 1" or
        /// "Evening Talkshow".
        public let name: String

        /// The day's entries, in the order the backend sent them.
        ///
        /// They do not arrive in time order, so a caller showing a running
        /// order sorts by `startTime` itself.
        public let slots: [Slot]

        /// An identity built from the name and the date.
        ///
        /// The API sends no identifier for a day, so a list keyed by this value
        /// treats two days sharing a name and a date as one. Renaming a day
        /// changes its identity.
        public var id: String {
            "\(name)-\(date.timeIntervalSince1970.description)"
        }

        /// Creates a day.
        ///
        /// - Parameters:
        ///   - date: The calendar day this day covers.
        ///   - name: The organizers' name for the day.
        ///   - slots: The day's entries.
        public init(date: Foundation.Date, name: String, slots: [Slot]) {
            self.date = date
            self.name = name
            self.slots = slots
        }
    }

    /// One event in the conference series, such as SwiftLeeds 2026.
    ///
    /// The conference recurs, so a schedule always belongs to one event rather
    /// than to the conference itself.
    public struct Event: Codable, Identifiable, Sendable {
        /// The event's identity, assigned by the backend.
        ///
        /// No endpoint lists events, so this value is the only source of an
        /// event identifier.
        public let id: UUID

        /// The event's name, such as "SwiftLeeds 2026".
        public let name: String

        /// The venue, as one line of text.
        public let location: String

        /// The date the organizers set for the event.
        public let date: Foundation.Date

        /// Whole days from today until the event, negative once it has passed.
        ///
        /// Counted midnight to midnight in the device's current calendar and
        /// time zone, so the value moves when the device does.
        public var daysUntil: Int {
            Calendar.current.numberOfDays(to: date)
        }

        /// Creates an event.
        ///
        /// - Parameters:
        ///   - id: The event's identity, assigned by the backend.
        ///   - name: The event's name.
        ///   - location: The venue, as one line of text.
        ///   - date: The date the organizers set for the event.
        public init(id: UUID, name: String, location: String, date: Foundation.Date) {
            self.id = id
            self.name = name
            self.location = location
            self.date = date
        }
    }

    /// One entry in a day's running order: a presentation or an activity.
    public struct Slot: Identifiable, Sendable {
        /// The slot's identity, assigned by the backend.
        public let id: UUID

        /// The date of the day this slot belongs to.
        ///
        /// Every slot in one day carries that day's date, so this value does
        /// not order slots within a day.
        public let date: Foundation.Date?

        /// The start time as the organizers typed it, in "HH:mm".
        ///
        /// Nothing enforces the format and nothing reformats it, so a caller
        /// displays and sorts the string as it arrives.
        public let startTime: String

        /// The slot's length in minutes. `0` means nobody set a length.
        public let duration: Int

        /// The activity filling this slot, absent when a presentation fills it.
        public let activity: Activity?

        /// The presentation filling this slot, absent when an activity does.
        public let presentation: Presentation?

        private enum CodingKeys: CodingKey {
            case id, activity, presentation, date, startTime, duration
        }

        /// Creates a slot.
        ///
        /// - Parameters:
        ///   - id: The slot's identity, assigned by the backend.
        ///   - date: The date of the day this slot belongs to.
        ///   - startTime: The start time, in "HH:mm".
        ///   - duration: The slot's length in minutes.
        ///   - activity: The activity filling this slot.
        ///   - presentation: The presentation filling this slot.
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
    /// Creates a slot, refusing one that holds neither an activity nor a
    /// presentation.
    ///
    /// A slot holding both becomes an activity.
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

    /// Why a slot could not be decoded.
    public enum SlotError: Error {
        /// The slot held neither an activity nor a presentation.
        case invalidSlot
    }
}

// MARK: - Slot Equatable
extension Schedule.Slot: Equatable {
    /// Compares two slots by identity alone, never by their contents.
    public static func == (lhs: Schedule.Slot, rhs: Schedule.Slot) -> Bool {
        lhs.id == rhs.id
    }
}

private extension Calendar {
    /// Whole days from the start of today to the start of the given date.
    ///
    /// - Parameter date: The date to count to.
    /// - Returns: A negative count once the date has passed, or `0` when the
    ///   calendar reports no day component.
    func numberOfDays(to date: Date) -> Int {
        let fromDate = startOfDay(for: Date.now)
        let toDate = startOfDay(for: date)
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)

        return numberOfDays.day ?? 0
    }
}
