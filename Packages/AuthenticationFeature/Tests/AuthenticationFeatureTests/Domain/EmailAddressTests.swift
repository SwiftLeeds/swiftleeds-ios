import AuthenticationFeature
import Testing

@Suite struct EmailAddressTests {
    @Test func whenParsingValidEmailAddress_shouldReturnEmailAddress() throws {
        _ = try EmailAddress("person@example.com")
    }

    @Test func whenParsingEmptyString_shouldThrowEmpty() {
        #expect(throws: EmailAddress.ParsingError.empty) {
            try EmailAddress("")
        }
    }

    @Test func whenParsingEmailAddressWithSurroundingWhitespace_shouldTrim() throws {
        let sut = try EmailAddress("  person@example.com  ")
        #expect(String(sut) == "person@example.com")
    }

    @Test func whenDescribed_shouldShowValue() throws {
        let sut = try EmailAddress("person@example.com")
        #expect(String(describing: sut).contains("person@example.com"))
    }
}
