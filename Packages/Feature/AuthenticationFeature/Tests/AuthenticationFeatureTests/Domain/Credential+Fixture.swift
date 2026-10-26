import AuthenticationDomain

extension Credential {
    /// Any well-formed credential.
    ///
    /// Nothing in a test depends on these particular values.
    static var fixture: Credential {
        get throws {
            try Credential(
                emailAddress: EmailAddress("attendee@example.com"),
                ticketReference: TicketReference("ABCD-12"),
            )
        }
    }
}
