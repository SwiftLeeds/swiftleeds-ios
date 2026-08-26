import AuthenticationFeature
import Testing

@Suite struct CredentialTests {
    // Fails if Credential gains a description of its own that hides its members.
    @Test func whenDescribed_shouldShowEmailAndTicketReference() throws {
        let credential = Credential(
            email: try EmailAddress("person@example.com"),
            ticketReference: try TicketReference("ABCD-1")
        )

        let described = String(describing: credential)

        #expect(described.contains("person@example.com"))
        #expect(described.contains("ABCD-1"))
    }
}
