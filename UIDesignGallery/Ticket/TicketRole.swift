import SwiftUI

/// A standing a ticket grants, and what marks it on the ticket.
///
/// The colors are provisional. The roles are not: they are what the conference
/// already calls ticket holders.
struct TicketRole: Equatable, Hashable, Sendable {
    /// What the conference calls this standing.
    let name: String

    /// The name of the SF Symbol that stands for this standing.
    ///
    /// It is display text rather than a domain value, for the reason
    /// `SampleSession` gives.
    let symbol: String

    /// The flat color of the band.
    let color: Color

    /// The texture that repeats the color's meaning.
    let pattern: BandPattern
}

extension TicketRole {
    /// Someone who comes to the conference.
    static let attendee = TicketRole(
        name: "Attendee",
        symbol: "person.fill",
        color: Color(red: 0.30, green: 0.30, blue: 0.32),
        pattern: .blank,
    )

    /// Someone giving a session.
    static let speaker = TicketRole(
        name: "Speaker",
        symbol: "mic.fill",
        color: Color(red: 0.16, green: 0.38, blue: 0.70),
        pattern: .diagonalLines,
    )

    /// Someone from a company that pays for the conference.
    static let sponsor = TicketRole(
        name: "Sponsor",
        symbol: "building.2.fill",
        color: Color(red: 0.62, green: 0.36, blue: 0.04),
        pattern: .dots,
    )

    /// Someone helping run the conference.
    static let staff = TicketRole(
        name: "Staff",
        symbol: "hand.raised.fill",
        color: Color(red: 0.52, green: 0.32, blue: 0.72),
        pattern: .horizontalStripes,
    )
}
