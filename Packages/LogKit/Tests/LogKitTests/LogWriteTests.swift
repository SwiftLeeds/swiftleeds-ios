import LogKit
import Testing

@Suite struct LogWriteTests {
    @Test func whenLevelIsBelowMinimum_shouldNotWrite() {
        let recorder = LogRecorder()
        let sut = recorder.log.atLeast(.error)

        sut(.debug, "push", "ignored")

        #expect(recorder.events.isEmpty)
    }

    @Test func whenCategoryIsNotListed_shouldNotWrite() {
        let recorder = LogRecorder()
        let sut = recorder.log.only(["push"])

        sut(.error, "theme", "ignored")

        #expect(recorder.events.isEmpty)
    }

    @Test func whenConsentIsWithheld_shouldNotWrite() {
        let recorder = LogRecorder()
        let sut = recorder.log.consented { false }

        sut(.error, "push", "ignored")

        #expect(recorder.events.isEmpty)
    }

    @Test func whenCombined_shouldWriteToEveryDestinationOnce() {
        let first = LogRecorder()
        let second = LogRecorder()
        let sut = Log.combine([first.log, second.log])

        sut(.error, "push", "kept")

        #expect(first.events.count == 1)
        #expect(second.events.count == 1)
    }

    @Test func whenOneOfManyDestinationsAccepts_shouldStillWrite() {
        let quiet = LogRecorder()
        let loud = LogRecorder()
        let sut = Log.combine([quiet.log.atLeast(.critical), loud.log.atLeast(.debug)])

        sut(.info, "push", "partial")

        #expect(quiet.events.isEmpty)
        #expect(loud.events.map(\.message) == ["partial"])
    }

    @Test func whenGivenSeveralFields_shouldKeepThemInWrittenOrder() {
        let recorder = LogRecorder()

        recorder.log(.error, "push", "ordered", .open("first", 1), .hashed("second", "x"), .secret("third", true))

        #expect(recorder.events.first?.fields.map(\.name) == ["first", "second", "third"])
    }

    @Test func whenRecordingEvent_shouldCaptureCallSite() {
        let recorder = LogRecorder()

        recorder.log(.info, "push", "located")

        #expect(recorder.events.first?.source.file.hasSuffix("LogWriteTests.swift") == true)
    }
}
