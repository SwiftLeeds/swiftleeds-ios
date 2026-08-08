import AuthenticationFeature
import Testing

@Suite struct EmailAddressTests {
    @Test func whenParsingValidEmail_shouldNotThrow() throws {
        _ = try EmailAddress("person@example.com")
    }

    @Test func whenParsingEmptyString_shouldThrowEmpty() {
        #expect(throws: EmailAddress.ParsingError.empty) {
            try EmailAddress("")
        }
    }

    @Test func whenParsingEmailWithSurroundingWhitespace_shouldTrim() throws {
        let email = try EmailAddress("  person@example.com  ")
        #expect(String(email) == "person@example.com")
    }
}
