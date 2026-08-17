import Foundation
import LogKit
import LogKitUnified
import Testing

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
                """
                exercised \("registration", name: "category", privacy: .open) \
                for \("ada@example.com", name: "email", privacy: .hashed) \
                ref \("ABCD-1", name: "reference", privacy: .hashed) \
                token \("abc123", name: "token", privacy: .secret)
                """
            )
        }
    }

    @Test func whenSameCategoryIsUsedTwice_shouldNotTrap() {
        let sut = Log.unified(subsystem: subsystem, salt: salt)

        sut(.info, "push", "first")
        sut(.info, "push", "second")
    }
}
