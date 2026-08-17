import Foundation
import LogKit
import Testing

@testable import LogKitUnified

@Suite struct LogUnifiedTests {
    private let subsystem: LogSubsystem = "uk.co.swiftleeds.tests"
    private let salt = LogSalt(Data("fixed-for-tests".utf8))

    @Test func whenBuilt_shouldAcceptEveryLevelAndCategory() {
        let sut = Log.unified(subsystem: subsystem, salt: salt)

        #expect(sut.accepts(.debug, "push"))
        #expect(sut.accepts(.critical, "theme"))
    }

    @Test func whenWritingEveryLevelAndSensitivity_shouldReachUnifiedLogging() {
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

        #expect(sut.accepts(.info, "push"))
    }

    @Test func whenSameCategoryIsUsedTwice_shouldReuseItsLogger() {
        let sut = Log.unified(subsystem: subsystem, salt: salt)

        sut(.info, "push", "first")
        sut(.info, "push", "second")

        #expect(sut.accepts(.info, "push"))
    }
}
