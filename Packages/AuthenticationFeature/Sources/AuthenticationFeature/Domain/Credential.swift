/// What a ticket holder presents to sign in.
public struct Credential: Equatable, Hashable, Sendable {
    /// The ticket holder's email address.
    public let emailAddress: EmailAddress

    /// The reference of the ticket.
    public let ticketReference: TicketReference

    /// Creates a credential.
    public init(emailAddress: EmailAddress, ticketReference: TicketReference) {
        self.emailAddress = emailAddress
        self.ticketReference = ticketReference
    }
}
