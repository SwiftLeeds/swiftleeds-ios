import LogKit
import Testing

@Suite struct LogSubsystemTests {
    @Test func whenParsingBundleIdentifier_shouldReturnSubsystem() throws {
        let subsystem = try LogSubsystem("uk.co.swiftleeds.app")

        #expect(String(subsystem) == "uk.co.swiftleeds.app")
    }

    @Test func whenParsingEmptyString_shouldThrowEmpty() {
        #expect(throws: LogSubsystem.ParsingError.empty) {
            try LogSubsystem("")
        }
    }

    @Test(arguments: ["uk.co swiftleeds", " uk.co.swiftleeds", "uk.co.swiftleeds\n", "   ", "\t"])
    func whenParsingValueHoldingWhitespace_shouldThrowContainsWhitespace(_ value: String) {
        #expect(throws: LogSubsystem.ParsingError.containsWhitespace) {
            try LogSubsystem(value)
        }
    }

    @Test(arguments: ["SwiftLeeds", "uk.co.swiftleeds-app", "Sub/System:1"])
    func whenParsingValueOutsideReverseDNSForm_shouldReturnSubsystem(_ value: String) throws {
        let subsystem = try LogSubsystem(value)

        #expect(String(subsystem) == value)
    }
}
