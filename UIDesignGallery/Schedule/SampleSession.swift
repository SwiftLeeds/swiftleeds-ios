import Foundation

/// A session made up for the gallery.
///
/// Every field is display text rather than a domain value. The gallery exists
/// to show what a screen looks like, so it needs strings to draw and no rules
/// to enforce. The real `Session` lives in `ScheduleFeature`.
struct SampleSession: Identifiable, Equatable, Hashable, Sendable {
    /// Tells one sample session from another.
    let id: String

    /// When the session runs, as the row prints it.
    let time: String

    /// Where the session runs.
    let room: String

    /// What the session is called.
    let title: String

    /// Who gives the session.
    let speaker: String

    /// What the speaker does, and where.
    let speakerDetail: String

    /// What kind of session it is, or `nil` for an ordinary talk.
    let kind: String?

    /// How long until the session starts, or `nil` once it is not imminent.
    let startsIn: String?

    /// Whether this person saved the session.
    let isFavorite: Bool

    /// What the session is about.
    let summary: String

    /// The speaker's name, split so an avatar can abbreviate it.
    var speakerName: PersonNameComponents {
        let parts = speaker.split(separator: " ")
        return PersonNameComponents(
            givenName: parts.first.map(String.init),
            familyName: parts.last.map(String.init)
        )
    }
}

extension SampleSession {
    /// The three sessions the gallery shows on day one.
    static let dayOne: [SampleSession] = [opening, concurrency, accessibility]

    /// The session the gallery pushes when asked for a detail screen.
    static let opening = SampleSession(
        id: "opening",
        time: "09:30 - 10:15",
        room: "Main Hall",
        title: "Building a design system that survives its second year",
        speaker: "Ada Archer",
        speakerDetail: "Northern Software",
        kind: nil,
        startsIn: "in 12 min",
        isFavorite: true,
        summary: """
            A design system earns its keep the year after it ships. This talk is \
            about the parts that rot, and the parts that hold.
            """
    )

    /// A lightning talk, which shows the neutral kind badge.
    static let concurrency = SampleSession(
        id: "concurrency",
        time: "10:30 - 11:00",
        room: "Main Hall",
        title: "Swift concurrency, one year on",
        speaker: "Blake Brooks",
        speakerDetail: "Pennine Labs",
        kind: "Lightning",
        startsIn: nil,
        isFavorite: false,
        summary: "What changed once the compiler started checking the hard part."
    )

    /// A workshop, which shows a longer kind badge.
    static let accessibility = SampleSession(
        id: "accessibility",
        time: "11:15 - 12:30",
        room: "Studio",
        title: "Accessibility beyond VoiceOver",
        speaker: "Casey Cole",
        speakerDetail: "Aire Systems",
        kind: "Workshop",
        startsIn: nil,
        isFavorite: false,
        summary: "Switch Control, Voice Control and the settings nobody tests."
    )
}
