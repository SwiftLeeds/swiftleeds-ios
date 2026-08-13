import Foundation
import LogKit
import Testing

@Suite struct LogWriteTests {
    @Test func whenLevelIsBelowMinimum_shouldNotBuildFields() {
        let recorder = LogRecorder()
        let counter = CallCounter()
        let sut = recorder.log.atLeast(.error)

        sut(.debug, "push", "ignored", fields: counter.record())

        #expect(counter.count == 0)
        #expect(recorder.events.isEmpty)
    }

    @Test func whenCategoryIsNotListed_shouldNotBuildFields() {
        let recorder = LogRecorder()
        let counter = CallCounter()
        let sut = recorder.log.only(["push"])

        sut(.error, "theme", "ignored", fields: counter.record())

        #expect(counter.count == 0)
    }

    @Test func whenConsentIsWithheld_shouldNotBuildFields() {
        let recorder = LogRecorder()
        let counter = CallCounter()
        let sut = recorder.log.consented { false }

        sut(.error, "push", "ignored", fields: counter.record())

        #expect(counter.count == 0)
    }

    @Test func whenEventIsAccepted_shouldBuildFieldsExactlyOnce() {
        let counter = CallCounter()
        let sut = Log.combine([LogRecorder().log, LogRecorder().log, LogRecorder().log])

        sut(.error, "push", "kept", fields: counter.record())

        #expect(counter.count == 1)
    }

    @Test func whenWritingToNone_shouldNotBuildFields() {
        let counter = CallCounter()

        Log.none(.critical, "push", "nowhere", fields: counter.record())

        #expect(counter.count == 0)
    }

    @Test func whenOneOfManyDestinationsAccepts_shouldStillWrite() {
        let quiet = LogRecorder()
        let loud = LogRecorder()
        let sut = Log.combine([quiet.log.atLeast(.critical), loud.log.atLeast(.debug)])

        sut(.info, "push", "partial")

        #expect(quiet.events.isEmpty)
        #expect(loud.events.map(\.message) == ["partial"])
    }

    @Test func whenRecordingEvent_shouldCaptureCallSite() {
        let recorder = LogRecorder()

        recorder.log(.info, "push", "located")

        #expect(recorder.events.first?.source.file.hasSuffix("LogWriteTests.swift") == true)
    }
}

private final class CallCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var storage = 0

    var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return storage
    }

    func record() -> LogFields {
        lock.lock()
        defer { lock.unlock() }
        storage += 1
        return [.open("built", true)]
    }
}
