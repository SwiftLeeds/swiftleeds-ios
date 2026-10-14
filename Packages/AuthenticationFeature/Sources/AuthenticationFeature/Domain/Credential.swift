public struct Credential: Equatable, Hashable, Sendable {
    public let emailAddress: EmailAddress
    public let ticketReference: TicketReference

    public init(emailAddress: EmailAddress, ticketReference: TicketReference) {
        self.emailAddress = emailAddress
        self.ticketReference = ticketReference
    }
}
