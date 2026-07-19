struct AttendeeCredentials: Equatable, Hashable, Sendable {
    let emailAddress: EmailAddress
    let ticketCredential: TicketCredential
}
