import AuthenticationFeature
import Testing

@Suite struct SessionTokenTests {
    @Test func whenDescribed_shouldRedactValue() throws {
        let token = try SessionToken("jwt-abc-123")

        #expect(!String(describing: token).contains("jwt-abc-123"))
    }

    @Test func whenCreatedWithSurroundingWhitespace_shouldTrim() throws {
        let sut = try SessionToken("  jwt-abc-123\n")

        #expect(String(sut) == "jwt-abc-123")
    }

    /// A 200 with an empty body would otherwise become a token that is stored in the keychain and
    /// sent as an Authorization header, surfacing much later as 401s that read as session expiry.
    @Test(arguments: ["", " ", "\n", "   \t  "])
    func whenCreatedFromBlankString_shouldThrowEmpty(value: String) {
        #expect(throws: SessionToken.ParsingError.empty) {
            try SessionToken(value)
        }
    }
}
