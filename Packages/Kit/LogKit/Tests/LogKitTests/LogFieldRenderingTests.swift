import LogKit
import Testing

/// Fields reach a destination already classified, so these cover only the joining. Tokenising and
/// secret removal are covered by `LogDestinationTests`.
@Suite struct LogFieldRenderingTests {
    @Test func whenRenderingWithoutSecrets_shouldKeepWrittenOrder() {
        let sut: LogFields = [.open("second", 2), .open("first", "x"), .open("third", 3)]

        #expect(sut.renderedWithoutSecrets == "second=2 first=x third=3")
    }

    @Test func whenRenderingWithoutSecrets_shouldExcludeSecretFields() {
        let sut: LogFields = [.open("scheme", "ticket"), .secret("token", "abc")]

        #expect(sut.renderedWithoutSecrets == "scheme=ticket")
    }

    @Test func whenRenderingWithoutSecrets_shouldIncludeHashedFields() {
        let sut: LogFields = [.hashed("email", "a1b2c3")]

        #expect(sut.renderedWithoutSecrets == "email=a1b2c3")
    }

    @Test func whenRenderingSecrets_shouldIncludeOnlySecretFields() {
        let sut: LogFields = [.open("scheme", "ticket"), .secret("token", "abc")]

        #expect(sut.renderedSecrets == "token=abc")
    }

    @Test func whenRenderingNoFields_shouldProduceEmptyString() {
        #expect(LogFields().renderedWithoutSecrets.isEmpty)
        #expect(LogFields().renderedSecrets.isEmpty)
    }
}
