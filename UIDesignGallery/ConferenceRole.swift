import SwiftUI

/// A standing the conference grants, and the colors that mark it.
///
/// The colors are provisional. The roles are not: they are what the conference
/// already calls people.
struct ConferenceRole: Equatable, Hashable, Sendable {
    /// What the conference calls this standing.
    let name: String

    /// The colors a ring runs between.
    let colors: [Color]
}

extension ConferenceRole {
    /// Someone giving a session.
    static let speaker = ConferenceRole(
        name: "Speaker",
        colors: [.init(red: 0.35, green: 0.66, blue: 0.44), .init(red: 0.22, green: 0.46, blue: 0.80)]
    )

    /// Someone helping run the conference on the day.
    static let volunteer = ConferenceRole(
        name: "Volunteer",
        colors: [.init(red: 0.93, green: 0.58, blue: 0.16), .init(red: 0.85, green: 0.28, blue: 0.24)]
    )

    /// Someone running the conference.
    static let organizer = ConferenceRole(
        name: "Organizer",
        colors: [.init(red: 0.52, green: 0.32, blue: 0.72), .init(red: 0.22, green: 0.46, blue: 0.80)]
    )

    /// A company paying at the top tier.
    static let headlineSponsor = ConferenceRole(
        name: "Headline sponsor",
        colors: [.init(red: 0.93, green: 0.78, blue: 0.36), .init(red: 0.85, green: 0.52, blue: 0.16)]
    )
}
