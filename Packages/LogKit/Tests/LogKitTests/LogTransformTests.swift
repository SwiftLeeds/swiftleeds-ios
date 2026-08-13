import LogKit
import Testing

@Suite struct LogTransformTests {
    @Test func whenPullingBack_shouldRewriteEventBeforeWriting() {
        let recorder = LogRecorder()
        let sut = recorder.log.pullback { event in
            LogEvent(level: .critical, category: event.category, message: event.message)
        }

        sut.write(.stub("raised", level: .debug))

        #expect(recorder.events.map(\.level) == [.critical])
    }

    @Test func whenFilteredOut_shouldWriteNothing() {
        let recorder = LogRecorder()
        let sut = recorder.log.filtered { _ in false }

        sut.write(.stub())

        #expect(recorder.events.isEmpty)
    }

    @Test func whenBelowMinimumLevel_shouldWriteNothing() {
        let recorder = LogRecorder()
        let sut = recorder.log.atLeast(.error)

        sut.write(.stub("quiet", level: .notice))

        #expect(recorder.events.isEmpty)
    }

    @Test func whenAtOrAboveMinimumLevel_shouldWriteEvent() {
        let recorder = LogRecorder()
        let sut = recorder.log.atLeast(.error)

        sut.write(.stub("loud", level: .error))
        sut.write(.stub("louder", level: .critical))

        #expect(recorder.events.map(\.message) == ["loud", "louder"])
    }

    @Test func whenCategoryIsNotListed_shouldWriteNothing() {
        let recorder = LogRecorder()
        let sut = recorder.log.only(["push"])

        sut.write(.stub("theme", category: "theme"))

        #expect(recorder.events.isEmpty)
    }

    @Test func whenCategoryIsListed_shouldWriteEvent() {
        let recorder = LogRecorder()
        let sut = recorder.log.only(["push", "theme"])

        sut.write(.stub("registered", category: "push"))

        #expect(recorder.events.map(\.message) == ["registered"])
    }

    @Test func whenDroppingSecrets_shouldRemoveOnlySecretFields() {
        let recorder = LogRecorder()
        let sut = recorder.log.droppingSecrets()

        sut.write(
            LogEvent(
                level: .info,
                category: "auth",
                message: "signed in",
                fields: [.open("scheme", "ticket"), .secret("token", "abc"), .hashed("email", "a@b.c")]
            )
        )

        #expect(recorder.events.first?.fields.map(\.name) == ["scheme", "email"])
    }

    @Test func whenEnriching_shouldAppendContextAfterEventFields() {
        let recorder = LogRecorder()
        let sut = recorder.log.enriching { [.open("build", "42")] }

        sut.write(
            LogEvent(level: .info, category: "app", message: "launched", fields: [.open("cold", true)])
        )

        #expect(recorder.events.first?.fields.map(\.name) == ["cold", "build"])
    }

    @Test func whenConsentIsWithheld_shouldWriteNothing() {
        let recorder = LogRecorder()
        let sut = recorder.log.consented { false }

        sut.write(.stub())

        #expect(recorder.events.isEmpty)
    }

    @Test func whenConsentIsWithdrawnBetweenEvents_shouldStopWriting() {
        let recorder = LogRecorder()
        let consent = Consent()
        let sut = recorder.log.consented { consent.isGranted }

        sut.write(.stub("before"))
        consent.isGranted = false
        sut.write(.stub("after"))

        #expect(recorder.events.map(\.message) == ["before"])
    }
}

private final class Consent: @unchecked Sendable {
    var isGranted = true
}
