import Foundation

public struct Profile: Equatable, Hashable, Sendable {
    public let name: PersonNameComponents
    public let emailAddress: String
    public let avatarURL: URL
    public let ticketReference: String
    public let ticketSlug: TicketSlug

    public init(
        name: PersonNameComponents,
        emailAddress: String,
        avatarURL: URL,
        ticketReference: String,
        ticketSlug: TicketSlug
    ) {
        self.name = name
        self.emailAddress = emailAddress
        self.avatarURL = avatarURL
        self.ticketReference = ticketReference
        self.ticketSlug = ticketSlug
    }
}

extension Profile {
    package init(_ attendee: Attendee) {
        self.init(
            name: attendee.name,
            emailAddress: String(attendee.emailAddress),
            avatarURL: URL(attendee.avatarURL),
            ticketReference: String(attendee.ticketReference),
            ticketSlug: attendee.ticketSlug
        )
    }
}
