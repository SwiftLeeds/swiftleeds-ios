import Foundation

/// A session made up for the gallery.
///
/// Its text fields are display text rather than domain values, and its dates
/// are built relative to today so "Today" and "Tomorrow" stay true. The real
/// `Session` lives in `ScheduleFeature`.
struct SampleSession: Identifiable, Equatable, Hashable, Sendable {
    /// Tells one sample session from another.
    let id: String

    /// Which conference the session belongs to, as a heading prints it.
    let conference: String

    /// Which day of the conference the session runs on.
    let day: String

    /// When the session starts.
    let start: Date

    /// When the session ends.
    let end: Date

    /// Where the session runs.
    let room: String

    /// What the session is called.
    let title: String

    /// Who gives the session, in the order the screen lists them.
    let speakers: [SamplePerson]

    /// What kind of session it is, or `nil` for an ordinary talk.
    let kind: String?

    /// How long until the session starts, or `nil` once it is not imminent.
    let startsIn: String?

    /// Whether this person favourited the session.
    let isFavorite: Bool

    /// What the session is about.
    let summary: String

    /// When the session runs, as a time range in the current locale.
    var time: String {
        (start..<end).formatted(Date.IntervalFormatStyle(date: .omitted, time: .shortened))
    }
}

extension SampleSession {
    /// The day the session runs, relative to now.
    ///
    /// "Today" or "Tomorrow" when either applies, else the weekday and date.
    var dayLabel: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(start) || calendar.isDateInTomorrow(start) {
            let relative = start.formatted(
                Date.RelativeFormatStyle(
                    allowedFields: [.day],
                    presentation: .named,
                    unitsStyle: .wide,
                )
            )
            return relative.prefix(1).uppercased() + relative.dropFirst()
        }
        return start.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))
    }
}

extension SampleSession {
    /// Returns a moment a number of days from today, at the given time.
    ///
    /// - Parameters:
    ///   - days: How many days from today. A negative number is the past.
    ///   - hour: The hour, on a 24-hour clock.
    ///   - minute: The minute past the hour.
    private static func daysFromToday(_ days: Int, at hour: Int, _ minute: Int) -> Date {
        let calendar = Calendar.current
        let day = calendar.date(byAdding: .day, value: days, to: .now) ?? .now
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
    }

    /// The three sessions the gallery shows on day one.
    static let dayOne: [SampleSession] = [opening, concurrency, accessibility]

    /// The sessions given at earlier conferences.
    static let earlier: [SampleSession] = [untestable]

    /// The session the gallery pushes when asked for a detail screen.
    static let opening = SampleSession(
        id: "opening",
        conference: "SwiftLeeds 2026",
        day: "Day 1",
        start: daysFromToday(0, at: 9, 30),
        end: daysFromToday(0, at: 10, 15),
        room: "Main Hall",
        title: "Building a design system that survives its second year",
        speakers: [.dana],
        kind: nil,
        startsIn: "in 12 min",
        isFavorite: true,
        summary: """
            A design system earns its keep the year after it ships. This talk is \
            about the parts that rot, and the parts that hold.
            """,
    )

    /// A lightning talk, which shows the neutral kind badge.
    static let concurrency = SampleSession(
        id: "concurrency",
        conference: "SwiftLeeds 2026",
        day: "Day 1",
        start: daysFromToday(0, at: 10, 30),
        end: daysFromToday(0, at: 11, 0),
        room: "Main Hall",
        title: "Swift concurrency, one year on",
        speakers: [.blake],
        kind: "Lightning",
        startsIn: nil,
        isFavorite: false,
        summary: "What changed once the compiler started checking the hard part.",
    )

    /// A workshop with two speakers, which shows a longer kind badge.
    static let accessibility = SampleSession(
        id: "accessibility",
        conference: "SwiftLeeds 2026",
        day: "Day 2",
        start: daysFromToday(1, at: 11, 15),
        end: daysFromToday(1, at: 12, 30),
        room: "Studio",
        title: "Accessibility beyond VoiceOver",
        speakers: [.casey, .fay],
        kind: "Workshop",
        startsIn: nil,
        isFavorite: false,
        summary: "Switch Control, Voice Control and the settings nobody tests.",
    )

    /// A talk from the year before, which shows under a speaker's previous
    /// talks.
    static let untestable = SampleSession(
        id: "untestable",
        conference: "SwiftLeeds 2025",
        day: "Day 2",
        start: daysFromToday(-365, at: 14, 0),
        end: daysFromToday(-365, at: 14, 40),
        room: "Main Hall",
        title: "Testing the untestable",
        speakers: [.dana],
        kind: nil,
        startsIn: nil,
        isFavorite: false,
        summary: "Putting a test around the code everyone is afraid to touch.",
    )
}
