import AuthenticationFeature
import Testing

@Suite struct CredentialTests {
    // The member tests cover each type alone. This covers an aggregate gaining its own redaction.
    @Test func whenDescribed_shouldShowEmailAndTicket() throws {
        let credential = Credential(
            email: try EmailAddress("person@example.com"),
            ticketReference: try TicketReference("ABCD-1")
        )

        let described = String(describing: credential)

        #expect(described.contains("person@example.com"))
        #expect(described.contains("ABCD-1"))
    }
}
