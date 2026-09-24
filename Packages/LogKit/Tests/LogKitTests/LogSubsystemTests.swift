import LogKit
import Testing

@Suite struct LogSubsystemTests {
    @Test func whenParsingBundleIdentifier_shouldReturnSubsystem() throws {
        let subsystem = try LogSubsystem("uk.co.swiftleeds.app")

        #expect(String(subsystem) == "uk.co.swiftleeds.app")
    }

    @Test func whenParsingEmptyString_shouldThrowBlank() {
        #expect(throws: LogSubsystem.ParsingError.blank) {
            try LogSubsystem("")
        }
    }

    @Test(arguments: ["   ", "\t", "\n", " \t\n "])
    func whenParsingOnlyWhitespace_shouldThrowBlank(_ value: String) {
        #expect(throws: LogSubsystem.ParsingError.blank) {
            try LogSubsystem(value)
        }
    }

    @Test(arguments: ["uk.co swiftleeds", " uk.co.swiftleeds", "uk.co.swiftleeds\n"])
    func whenParsingNameHoldingWhitespace_shouldReturnSubsystemUnchanged(
        _ value: String
    ) throws {
        let subsystem = try LogSubsystem(value)

        #expect(String(subsystem) == value)
    }

    @Test(arguments: ["SwiftLeeds", "uk.co.swiftleeds-app", "Sub/System:1"])
    func whenParsingNameOutsideReverseDNSForm_shouldReturnSubsystem(
        _ value: String
    ) throws {
        let subsystem = try LogSubsystem(value)

        #expect(String(subsystem) == value)
    }
}
