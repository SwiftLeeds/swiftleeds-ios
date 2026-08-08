import AuthenticationFeature
import Testing

@Suite struct TicketReferenceTests {
    @Test func whenParsingValidReference_shouldNotThrow() throws {
        _ = try TicketReference("ABCD-1")
    }
}
