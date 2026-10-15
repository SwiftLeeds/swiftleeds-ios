import Foundation

/// An attendee's details, for callers outside the package.
public struct Profile: Equatable, Hashable, Sendable {
    /// The attendee's name.
    public let name: PersonNameComponents

    /// The attendee's email address.
    public let emailAddress: String

    /// The address of the attendee's avatar image.
    public let avatarURL: URL

    /// The attendee's ticket reference.
    public let ticketReference: String

    /// The ticketing provider's identifier for the ticket.
    public let ticketSlug: TicketSlug

    /// Creates a profile.
    public init(
        name: PersonNameComponents,
        emailAddress: String,
        avatarURL: URL,
        ticketReference: String,
        ticketSlug: TicketSlug,
    ) {
        self.name = name
        self.emailAddress = emailAddress
        self.avatarURL = avatarURL
        self.ticketReference = ticketReference
        self.ticketSlug = ticketSlug
    }
}

extension Profile {
    /// Creates a profile from an attendee.
    /// - Parameter attendee: The attendee to convert.
    package init(_ attendee: Attendee) {
        self.init(
            name: attendee.name,
            emailAddress: String(attendee.emailAddress),
            avatarURL: URL(attendee.avatarURL),
            ticketReference: String(attendee.ticketReference),
            ticketSlug: attendee.ticketSlug,
        )
    }
}
