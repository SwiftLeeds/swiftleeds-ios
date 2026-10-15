import LogKit
import Testing

@Suite struct LogLevelTests {
    @Test func whenComparingSeverities_shouldOrderDebugLowestAndCriticalHighest() {
        #expect(LogLevel.allCases.sorted() == [.debug, .info, .notice, .warning, .error, .critical])
    }

    @Test func whenLevelIsMoreSevere_shouldCompareGreater() {
        #expect(LogLevel.error > LogLevel.notice)
    }
}
