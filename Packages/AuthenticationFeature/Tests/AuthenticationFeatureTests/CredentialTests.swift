import AuthenticationFeature
import Testing

@Suite struct CredentialTests {
    @Test func whenDescribed_shouldRedactEmailAndTicket() throws {
        let credential = Credential(
            email: try EmailAddress("person@example.com"),
            ticketReference: try TicketReference("ABCD-1")
        )

        let described = String(describing: credential)

        #expect(!described.contains("person@example.com"))
        #expect(!described.contains("ABCD-1"))
    }
}
