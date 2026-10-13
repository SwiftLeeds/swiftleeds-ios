import Foundation

/// A person made up for the gallery.
///
/// Every field is display text rather than a domain value, for the reason
/// `SampleSession` gives.
struct SampleAttendee: Identifiable, Equatable, Hashable, Sendable {
    /// Tells one sample attendee from another.
    var id: String { name }

    /// What the person is called.
    let name: String

    /// What the person does, and where.
    let detail: String

    /// The standing the conference grants this person.
    let role: ConferenceRole

    /// How many SwiftLeeds this person has come to, as a badge prints it.
    let tenure: String

    /// Which attendee this person is, in the order people first registered.
    let number: String

    /// When this person first registered.
    let joined: String

    /// What this person's ticket admits them to.
    let ticket: String

    /// How many sessions this person has saved.
    let savedSessions: String

    /// Where the conference writes to this person.
    let email: String

    /// The person's name, split so an avatar can abbreviate it.
    var nameComponents: PersonNameComponents {
        let parts = name.split(separator: " ")
        return PersonNameComponents(
            givenName: parts.first.map(String.init),
            familyName: parts.last.map(String.init),
        )
    }
}

extension SampleAttendee {
    /// The person the gallery signs in as.
    static let signedIn = SampleAttendee(
        name: "Ada Archer",
        detail: "iOS at Northern Software",
        role: .organizer,
        tenure: "6th SwiftLeeds",
        number: "Attendee #412",
        joined: "Joined August 2019",
        ticket: "Conference and workshops",
        savedSessions: "6",
        email: "ada@northern.software",
    )
}
