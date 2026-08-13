import Foundation

package struct Attendee: Equatable, Hashable, Sendable {
    package let name: PersonNameComponents
    package let emailAddress: EmailAddress
    package let avatarURL: AvatarURL
    package let ticketReference: TicketReference
    package let ticketSlug: TicketSlug

    package init(
        name: PersonNameComponents,
        emailAddress: EmailAddress,
        avatarURL: AvatarURL,
        ticketReference: TicketReference,
        ticketSlug: TicketSlug
    ) {
        self.name = name
        self.emailAddress = emailAddress
        self.avatarURL = avatarURL
        self.ticketReference = ticketReference
        self.ticketSlug = ticketSlug
    }
}
