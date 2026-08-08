import AuthenticationFeature
import Testing

@Suite struct TicketReferenceTests {
    @Test func whenParsingValidReference_shouldNotThrow() throws {
        _ = try TicketReference("ABCD-1")
    }

    @Test func whenParsingDoubleDigitReference_shouldReturnTicketReference() throws {
        let reference = try TicketReference("ABCD-12")
        #expect(String(reference) == "ABCD-12")
    }
}
