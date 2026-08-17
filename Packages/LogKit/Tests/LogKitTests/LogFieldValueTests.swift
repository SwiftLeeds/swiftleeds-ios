import LogKit
import Testing

/// Every value here is held in a variable rather than written as a literal.
/// `LogValue` is `ExpressibleByStringLiteral`, so a literal would compile even
/// without these conformances and would hide the gap these cover.
@Suite struct LogFieldValueTests {
    @Test func whenBuiltFromStringVariable_shouldNeedNoExplicitCase() {
        let value = "https://example.com/push"

        #expect(LogField.open("url", value).value == .string(value))
    }

    @Test func whenBuiltFromIntegerVariable_shouldStayNumber() {
        let value = 401

        #expect(LogField.open("status", value).value == .integer(value))
    }

    @Test func whenBuiltFromDoubleVariable_shouldStayDouble() {
        let value = 1.5

        #expect(LogField.open("duration", value).value == .double(value))
    }

    @Test func whenBuiltFromBooleanVariable_shouldStayBoolean() {
        let value = true

        #expect(LogField.open("retried", value).value == .boolean(value))
    }

    @Test func whenBuiltFromLogValueVariable_shouldPassItThrough() {
        let value = LogValue.array(["a", "b"])

        #expect(LogField.open("tags", value).value == value)
    }

    @Test(arguments: [Sensitivity.open, .hashed, .secret])
    func whenBuiltFromVariable_shouldKeepTheChosenSensitivity(sensitivity: Sensitivity) {
        let value = "ada@example.com"

        let sut = switch sensitivity {
        case .open: LogField.open("email", value)
        case .hashed: LogField.hashed("email", value)
        case .secret: LogField.secret("email", value)
        }

        #expect(sut.sensitivity == sensitivity)
        #expect(sut.value == .string(value))
    }
}
