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

    /// A hashed ticket reference that converts itself to a log value.
    private struct ReferenceStub: LogValueConvertible {
        /// The fixed ticket reference as a string.
        var logValue: LogValue { .string("ABCD-1") }

        /// Hashed, because a ticket reference identifies an attendee.
        var sensitivity: Sensitivity { .hashed }
    }

    /// A credential that lists its email and reference as log fields.
    private struct CredentialStub: Loggable {
        /// The email field, then the reference field.
        var logFields: LogFields {
            [LogField("email", EmailStub()), LogField("reference", ReferenceStub())]
        }
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

    @Test func whenComposingLoggable_shouldProduceFieldsInWrittenOrder() {
        let sut = CredentialStub()

        #expect(sut.logFields.map(\.name) == ["email", "reference"])
        #expect(sut.logFields.map(\.sensitivity) == [.hashed, .hashed])
    }
}
