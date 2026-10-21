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

    /// What kind of session it is.
    let kind: SessionKind

    /// How long until the session starts, or `nil` once it is not imminent.
    let startsIn: String?

    /// Whether this person favourited the session.
    let isFavorite: Bool

    /// What the session is about.
    let summary: String

    /// A line or two that sells the session, for the top of its detail screen.
    let teaser: String

    /// How long the session runs.
    var duration: Duration {
        .seconds(end.timeIntervalSince(start))
    }

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
        dayLabel(now: .now)
    }

    /// Returns the day the session runs, as seen from a given moment.
    ///
    /// - Parameter now: The moment the day is seen from.
    /// - Returns: "Today" or "Tomorrow" when either applies, else the weekday and date.
    func dayLabel(now: Date) -> String {
        let calendar = Calendar.current
        let seen = start.addingTimeInterval(Date.now.timeIntervalSince(now))
        if calendar.isDateInToday(seen) || calendar.isDateInTomorrow(seen) {
            let relative = seen.formatted(
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
        kind: .talk,
        startsIn: "in 12 min",
        isFavorite: true,
        summary: """
            A design system earns its keep the year after it ships. This talk is \
            about the parts that rot, and the parts that hold.
            """,
        teaser: "Why most design systems stall in year two, and the habits that keep one alive.",
    )

    /// A lightning talk.
    static let concurrency = SampleSession(
        id: "concurrency",
        conference: "SwiftLeeds 2026",
        day: "Day 1",
        start: daysFromToday(0, at: 10, 30),
        end: daysFromToday(0, at: 11, 0),
        room: "Main Hall",
        title: "Swift concurrency, one year on",
        speakers: [.blake],
        kind: .lightningTalk,
        startsIn: nil,
        isFavorite: false,
        summary: "What changed once the compiler started checking the hard part.",
        teaser: "Twelve months of strict checking, and what it caught in real apps.",
    )

    /// A workshop with two speakers.
    static let accessibility = SampleSession(
        id: "accessibility",
        conference: "SwiftLeeds 2026",
        day: "Day 2",
        start: daysFromToday(1, at: 11, 15),
        end: daysFromToday(1, at: 12, 30),
        room: "Studio",
        title: "Accessibility beyond VoiceOver",
        speakers: [.casey, .fay],
        kind: .workshop,
        startsIn: nil,
        isFavorite: false,
        summary: """
            Switch Control, Voice Control and the settings nobody tests. Most \
            apps are checked with VoiceOver and little else. In this workshop \
            you will drive your own app with a single switch, then with your \
            voice alone, and fix what breaks. You will leave with a short list \
            of checks that your team can run before every release.
            """,
        teaser: "Drive your own app with one switch, then your voice, and fix what breaks.",
    )

    /// A drop-in session in the second room, which the schedule does not list.
    static let dropIn = SampleSession(
        id: "dropin",
        conference: "SwiftLeeds 2026",
        day: "Day 1",
        start: daysFromToday(0, at: 13, 0),
        end: daysFromToday(0, at: 14, 0),
        room: "Studio",
        title: "Ask the accessibility team",
        speakers: [.casey],
        kind: .dropIn,
        startsIn: nil,
        isFavorite: false,
        summary: "Bring a screen from your app and get a second pair of eyes on it.",
        teaser: "Show the team a screen you are unsure about and leave with a fix.",
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
        kind: .talk,
        startsIn: nil,
        isFavorite: false,
        summary: "Putting a test around the code everyone is afraid to touch.",
        teaser: "A practical way to cover the code that nobody dares to change.",
    )
}
