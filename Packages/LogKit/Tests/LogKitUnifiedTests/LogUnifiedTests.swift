import Foundation
import LogKit
import Testing

@testable import LogKitUnified

/// Unified logging cannot be read back from a test process, so these exercise every path for a
/// trap or a precondition failure rather than asserting on output. What the destination *renders*
/// is covered by `LogValueRenderingTests`.
@Suite struct LogUnifiedTests {
    private let subsystem: LogSubsystem = "uk.co.swiftleeds.tests"
    private let salt = LogSalt(Data("fixed-for-tests".utf8))

    @Test func whenWritingEveryLevelAndSensitivity_shouldNotTrap() {
        let sut = Log.unified(subsystem: subsystem, salt: salt)

        for level in LogLevel.allCases {
            sut(
                level,
                "push",
                "exercised every sensitivity",
                .open("category", "registration"),
                .hashed("email", "ada@example.com"),
                .hashed("reference", "ABCD-1"),
                .secret("token", "abc123")
            )
        }
    }

    @Test func whenSameCategoryIsUsedTwice_shouldNotTrap() {
        let sut = Log.unified(subsystem: subsystem, salt: salt)

        sut(.info, "push", "first")
        sut(.info, "push", "second")
    }
}
