import AuthenticationFeature
import Testing

@Suite struct SessionTokenTests {
    @Test func whenDescribed_shouldRedactValue() {
        let token = SessionToken("jwt-abc-123")
        #expect(!String(describing: token).contains("jwt-abc-123"))
    }

    @Test func whenCreatedWithSurroundingWhitespace_shouldTrim() {
        let sut = SessionToken("  jwt-abc-123\n")
        #expect(String(sut) == "jwt-abc-123")
    }
}
