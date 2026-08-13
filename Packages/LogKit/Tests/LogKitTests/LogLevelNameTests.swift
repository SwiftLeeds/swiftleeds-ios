import LogKit
import Testing

@Suite struct LogLevelNameTests {
    @Test(arguments: zip(LogLevel.allCases, ["debug", "info", "notice", "warning", "error", "critical"]))
    func whenNamed_shouldMatchItsCase(_ level: LogLevel, _ expected: String) {
        #expect(level.name == expected)
    }

    @Test func whenNoticeAndWarningShareAnOSLogType_shouldStillHaveDistinctNames() {
        #expect(LogLevel.notice.name != LogLevel.warning.name)
    }
}
