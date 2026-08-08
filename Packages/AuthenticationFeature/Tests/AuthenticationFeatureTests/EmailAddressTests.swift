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
}
