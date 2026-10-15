import Foundation

/// A session made up for the gallery.
///
/// Every field is display text rather than a domain value. The gallery exists
/// to show what a screen looks like, so it needs strings to draw and no rules
/// to enforce. The real `Session` lives in `ScheduleFeature`.
struct SampleSession: Identifiable, Equatable, Hashable, Sendable {
    /// Tells one sample session from another.
    let id: String

    /// Which conference the session belongs to, as a heading prints it.
    let conference: String

    /// Which day of the conference the session runs on.
    let day: String

    /// The date the session runs on.
    let date: Date

    /// When the session runs, as the row prints it.
    let time: String

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
}

extension SampleSession {
    /// Returns the date a number of days from today, read at launch.
    ///
    /// - Parameter days: How many days from today. A negative number is the
    ///   past.
    private static func daysFromToday(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: .now) ?? .now
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
        date: daysFromToday(0),
        time: "09:30 - 10:15",
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
        date: daysFromToday(0),
        time: "10:30 - 11:00",
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
        date: daysFromToday(1),
        time: "11:15 - 12:30",
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
        date: daysFromToday(-365),
        time: "14:00 - 14:40",
        room: "Main Hall",
        title: "Testing the untestable",
        speakers: [.dana],
        kind: nil,
        startsIn: nil,
        isFavorite: false,
        summary: "Putting a test around the code everyone is afraid to touch.",
    )
}
