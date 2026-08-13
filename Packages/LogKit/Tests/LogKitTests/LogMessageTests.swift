import LogKit
import Testing

@Suite struct LogMessageTests {
    @Test func whenBuiltFromSameLiteral_shouldBeEqual() {
        let sut: LogMessage = "push registration failed"

        #expect(sut == LogMessage("push registration failed"))
    }

    @Test func whenBuiltFromDifferentLiteral_shouldNotBeEqual() {
        let sut: LogMessage = "push registration failed"

        #expect(sut != LogMessage("sign in failed"))
    }

    @Test func whenConvertedToString_shouldReturnLiteral() {
        let sut: LogMessage = "theme unavailable"

        #expect(String(sut) == "theme unavailable")
    }
}
