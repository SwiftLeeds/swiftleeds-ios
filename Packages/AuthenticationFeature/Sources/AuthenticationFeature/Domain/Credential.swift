public struct Credential: Equatable, Hashable, Sendable {
    public let email: EmailAddress
    public let ticketReference: TicketReference

    public init(email: EmailAddress, ticketReference: TicketReference) {
        self.email = email
        self.ticketReference = ticketReference
    }
}
