import LogKit
import Testing

@Suite struct LogValueConvertibleTests {
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

private struct EmailStub: LogValueConvertible {
    var logValue: LogValue { .string("ada@example.com") }
    var sensitivity: Sensitivity { .hashed }
}

private struct ReferenceStub: LogValueConvertible {
    var logValue: LogValue { .string("ABCD-1") }
    var sensitivity: Sensitivity { .hashed }
}

private struct CredentialStub: Loggable {
    var logFields: LogFields {
        [LogField("email", EmailStub()), LogField("reference", ReferenceStub())]
    }
}
