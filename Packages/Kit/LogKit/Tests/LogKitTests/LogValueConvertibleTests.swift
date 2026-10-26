import LogKit
import Testing

@Suite struct LogValueConvertibleTests {
    /// A hashed email address that converts itself to a log value.
    private struct EmailStub: LogValueConvertible {
        /// The fixed email address as a string.
        var logValue: LogValue { .string("ada@example.com") }

        /// Hashed, because an email address identifies a person.
        var sensitivity: Sensitivity { .hashed }
    }

    @Test func whenBuiltFromConvertibleValue_shouldTakeItsSensitivity() {
        let sut = LogField("email", EmailStub())

        #expect(sut.sensitivity == .hashed)
        #expect(sut.value == .string("ada@example.com"))
    }

    @Test func whenBuiltWithExplicitSensitivity_shouldOverrideTheTypesDefault() {
        let sut = LogField.open("email", EmailStub().logValue)

        #expect(sut.sensitivity == .open)
    }
}
