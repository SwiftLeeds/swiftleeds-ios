import AuthenticationFeature
import Testing

@Suite struct CredentialTests {
    // Fails if Credential gains a description of its own that hides its members.
    @Test func whenDescribed_shouldShowEmailAddressAndTicketReference() throws {
        let sut = Credential(
            emailAddress: try EmailAddress("person@example.com"),
            ticketReference: try TicketReference("ABCD-1"),
        )

        let described = String(describing: sut)

        #expect(described.contains("person@example.com"))
        #expect(described.contains("ABCD-1"))
    }
}
