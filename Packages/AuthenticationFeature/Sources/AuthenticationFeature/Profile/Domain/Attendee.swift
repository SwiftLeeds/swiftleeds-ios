import Foundation

/// A person who holds a ticket.
package struct Attendee: Equatable, Hashable, Sendable {
    /// The attendee's name.
    package let name: PersonNameComponents

    /// The attendee's email address.
    package let emailAddress: EmailAddress

    /// The address of the attendee's avatar image.
    package let avatarURL: AvatarURL

    /// The attendee's ticket reference.
    package let ticketReference: TicketReference

    /// The ticketing provider's identifier for the ticket.
    package let ticketSlug: TicketSlug

    /// Creates an attendee.
    package init(
        name: PersonNameComponents,
        emailAddress: EmailAddress,
        avatarURL: AvatarURL,
        ticketReference: TicketReference,
        ticketSlug: TicketSlug,
    ) {
        self.name = name
        self.emailAddress = emailAddress
        self.avatarURL = avatarURL
        self.ticketReference = ticketReference
        self.ticketSlug = ticketSlug
    }
}
