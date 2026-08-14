import LogKit
import Testing
import os

@testable import LogKitUnified

@Suite struct LogLevelOSLogTypeTests {
    @Test func whenMappingLevels_shouldUseNearestUnifiedType() {
        #expect(LogLevel.debug.osLogType == .debug)
        #expect(LogLevel.info.osLogType == .info)
        #expect(LogLevel.notice.osLogType == .default)
        #expect(LogLevel.error.osLogType == .error)
        #expect(LogLevel.critical.osLogType == .fault)
    }

    @Test func whenMappingWarning_shouldFallBackToDefaultSinceUnifiedHasNone() {
        #expect(LogLevel.warning.osLogType == .default)
    }
}
