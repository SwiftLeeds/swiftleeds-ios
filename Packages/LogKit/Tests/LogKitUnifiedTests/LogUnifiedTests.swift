import LogKit
import Testing

@testable import LogKitUnified

@Suite struct LogUnifiedTests {
    @Test func whenBuilt_shouldAcceptEveryLevelAndCategory() {
        let sut = Log.unified(subsystem: "uk.co.swiftleeds.tests")

        #expect(sut.accepts(.debug, "push"))
        #expect(sut.accepts(.critical, "theme"))
    }

    @Test func whenWritingEveryLevelAndSensitivity_shouldReachUnifiedLogging() {
        let sut = Log.unified(subsystem: "uk.co.swiftleeds.tests")

        for level in LogLevel.allCases {
            sut(
                level,
                "push",
                "exercised every sensitivity",
                fields: [
                    .open("category", "registration"),
                    .hashed("email", "ada@example.com"),
                    .secret("token", "abc123"),
                ]
            )
        }

        #expect(sut.accepts(.info, "push"))
    }

    @Test func whenSameCategoryIsUsedTwice_shouldReuseItsLogger() {
        let sut = Log.unified(subsystem: "uk.co.swiftleeds.tests")

        sut(.info, "push", "first")
        sut(.info, "push", "second")

        #expect(sut.accepts(.info, "push"))
    }
}
