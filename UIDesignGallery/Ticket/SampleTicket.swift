import Foundation

/// A ticket made up for the gallery.
///
/// Every field is display text rather than a domain value, for the reason
/// `SampleSession` gives.
struct SampleTicket: Identifiable, Equatable, Hashable, Sendable {
    /// Tells one sample ticket from another.
    var id: String { reference }

    /// What the person who holds the ticket is called.
    let holderName: String

    /// The company the holder speaks for, or `nil` when there is none.
    ///
    /// Only a sponsor's ticket names a company.
    let company: String?

    /// What the ticket lets its holder into.
    let admits: String

    /// The short text that names this ticket to a person at the door.
    let reference: String

    /// The standing the ticket grants.
    let role: TicketRole

    /// The text the QR code carries, or `nil` when the code will not draw.
    let code: String?
}

extension SampleTicket {
    /// The ticket of someone who comes to the conference.
    static let attendee = SampleTicket(
        holderName: "Blake Brooks",
        company: nil,
        admits: "Conference",
        reference: "SWL-9C3M-7D",
        role: .attendee,
        code: "swiftleeds-2026/SWL-9C3M-7D",
    )

    /// The ticket of someone giving a session.
    static let speaker = SampleTicket(
        holderName: "Casey Cole",
        company: nil,
        admits: "Conference and workshops",
        reference: "SWL-2R6W-9K",
        role: .speaker,
        code: "swiftleeds-2026/SWL-2R6W-9K",
    )

    /// The ticket of someone from a sponsor, which names their company.
    static let sponsor = SampleTicket(
        holderName: "Dana Dixon",
        company: "Northern Software",
        admits: "Conference and sponsor stand",
        reference: "SWL-7T1N-3B",
        role: .sponsor,
        code: "swiftleeds-2026/SWL-7T1N-3B",
    )

    /// The ticket of someone helping run the conference.
    static let staff = SampleTicket(
        holderName: "Ada Archer",
        company: nil,
        admits: "Conference and workshops",
        reference: "SWL-4F7K-2Q",
        role: .staff,
        code: "swiftleeds-2026/SWL-4F7K-2Q",
    )

    /// The ticket of someone who runs a drop-in session.
    static let host = SampleTicket(
        holderName: "Hana Hart",
        company: nil,
        admits: "Conference and drop-in room",
        reference: "SWL-6J4D-8H",
        role: .host,
        code: "swiftleeds-2026/SWL-6J4D-8H",
    )

    /// A ticket whose code will not draw.
    static let unavailable = SampleTicket(
        holderName: "Evan Ellis",
        company: nil,
        admits: "Conference",
        reference: "SWL-8H2P-5V",
        role: .attendee,
        code: nil,
    )

    /// The ticket of the person the gallery signs in as.
    ///
    /// That person is an organizer, so the ticket is a staff ticket.
    static let signedIn = staff

    /// Returns the ticket a launch argument names, or `nil` for any other text.
    ///
    /// - Parameter argument: The name of a role, or `unavailable`.
    static func named(_ argument: String) -> SampleTicket? {
        switch argument {
        case "attendee": attendee
        case "speaker": speaker
        case "sponsor": sponsor
        case "staff": staff
        case "host": host
        case "unavailable": unavailable
        default: nil
        }
    }
}
