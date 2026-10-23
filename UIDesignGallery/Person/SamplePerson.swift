import Foundation

/// A person made up for the gallery.
///
/// Every field is display text rather than a domain value, for the reason
/// `SampleSession` gives. A person holds no talks. Sessions hold the
/// people they credit, and a person's talks are found by looking through the sessions.
struct SamplePerson: Identifiable, Equatable, Hashable, Sendable {
    /// Tells one sample person from another.
    var id: String { name }

    /// What the person is called.
    let name: String

    /// What the person does, and where.
    let detail: String

    /// The standings the person holds.
    let roles: Roles

    /// What the person says about themselves, or `nil` when they say nothing.
    let bio: String?

    /// The pages the person publishes, in the order the page shows them.
    let links: [SampleLink]

    /// The sponsor this person speaks for, or `nil` when they speak for none.
    let represents: SampleSponsor?

    /// The person's name, split so an avatar can abbreviate it.
    var nameComponents: PersonNameComponents {
        let parts = name.split(separator: " ")
        return PersonNameComponents(
            givenName: parts.first.map(String.init),
            familyName: parts.last.map(String.init),
        )
    }

    /// The sessions at this year's conference that the person gives.
    var talksThisYear: [SampleSession] {
        SampleSession.dayOne.filter { $0.lineup.credited.contains(self) }
    }

    /// The sessions at earlier conferences that the person gave.
    var previousTalks: [SampleSession] {
        SampleSession.earlier.filter { $0.lineup.credited.contains(self) }
    }
}

extension SamplePerson {
    /// A speaker with a long bio and every kind of link.
    static let dana = SamplePerson(
        name: "Dana Dixon",
        detail: "iOS at Northern Software",
        roles: Roles(.speaker),
        bio: """
            Dana builds iOS apps for a living and design systems for fun. She \
            has spent a decade in Leeds shipping apps for banks, broadcasters \
            and a railway, and now leads the mobile team at Northern Software. \
            She cares most about the parts of an app nobody sees until they \
            break: accessibility, testing and the first minute after install. \
            She runs the Leeds iOS meetup, mentors two junior developers, and \
            still loses most arguments about tabs and spaces.
            """,
        links: [
            .website("dana.dev"),
            .gitHub("@danadixon"),
            .mastodon("@dana@mastodon.social"),
            .linkedIn("in/danadixon"),
            .x("@danadixon"),
        ],
        represents: nil,
    )

    /// A speaker with no bio and no links.
    static let blake = SamplePerson(
        name: "Blake Brooks",
        detail: "Pennine Labs",
        roles: Roles(.speaker),
        bio: nil,
        links: [],
        represents: nil,
    )

    /// A speaker with a short bio and two links.
    static let casey = SamplePerson(
        name: "Casey Cole",
        detail: "Aire Systems",
        roles: Roles(.speaker),
        bio: "Casey tests apps with the settings most people never turn on.",
        links: [.website("casey.example"), .gitHub("@caseycole")],
        represents: nil,
    )

    /// An attendee with a short bio and one link.
    static let eli = SamplePerson(
        name: "Eli Evans",
        detail: "Student at Leeds Beckett",
        roles: Roles(.attendee),
        bio: "Eli is in the last year of a computing degree and building a first app.",
        links: [.mastodon("@eli@mastodon.social")],
        represents: nil,
    )

    /// A sponsor's representative, who also speaks.
    static let fay = SamplePerson(
        name: "Fay Fisher",
        detail: "Developer advocate at Pennine Labs",
        roles: Roles(.sponsor, .speaker),
        bio: "Fay helps developers get the most from Pennine Labs' tools.",
        links: [.linkedIn("in/fayfisher"), .x("@fayfisher")],
        represents: SampleSponsor.sponsors(in: .gold).first,
    )

    /// A volunteer, who helps run the conference.
    static let gus = SamplePerson(
        name: "Gus Gray",
        detail: "Volunteer",
        roles: Roles(.staff),
        bio: "Gus has helped at the registration desk since 2022.",
        links: [],
        represents: nil,
    )

    /// Everyone the gallery shows.
    static let all: [SamplePerson] = [dana, blake, casey, eli, fay, gus]

    /// Returns the person a launch argument names, or `nil` for any other text.
    ///
    /// - Parameter argument: A person's first name, in lower case.
    static func named(_ argument: String) -> SamplePerson? {
        all.first { $0.name.lowercased().hasPrefix(argument.lowercased() + " ") }
    }
}
