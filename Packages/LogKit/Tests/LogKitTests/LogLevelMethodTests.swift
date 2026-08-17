import LogKit
import Testing

@Suite struct LogLevelMethodTests {
    @Test func whenLoggingAtEachLevel_shouldRecordThatLevel() {
        let recorder = LogRecorder()
        let sut = recorder.log

        sut.debug("d", in: "push")
        sut.info("i", in: "push")
        sut.notice("n", in: "push")
        sut.warning("w", in: "push")
        sut.error("e", in: "push")
        sut.critical("c", in: "push")

        #expect(recorder.events.map(\.level) == [.debug, .info, .notice, .warning, .error, .critical])
    }

    @Test func whenLogging_shouldCarryCategoryAndMessage() {
        let recorder = LogRecorder()

        recorder.log.error("The push URL is not a valid URL", in: "push")

        #expect(recorder.events.first?.category == "push")
        #expect(recorder.events.first?.message == "The push URL is not a valid URL")
    }

    @Test func whenGivenSeveralFields_shouldKeepThemInWrittenOrder() {
        let recorder = LogRecorder()

        recorder.log.error(
            "\(1, name: "first", privacy: .open) \("x", name: "second", privacy: .hashed) \(true, name: "third", privacy: .secret)",
            in: "push"
        )

        #expect(recorder.events.first?.fields.map { String($0.name) } == ["first", "second", "third"])
    }

    /// The literals must expand where the developer wrote the call, not inside the level method.
    @Test func whenLogging_shouldCaptureTheCallSiteNotTheHelper() {
        let recorder = LogRecorder()

        recorder.log.error("located", in: "push")

        #expect(recorder.events.first?.source.file.hasSuffix("LogLevelMethodTests.swift") == true)
    }

    @Test func whenLevelIsBelowMinimum_shouldNotWrite() {
        let recorder = LogRecorder()

        recorder.log.atLeast(.error).debug("ignored", in: "push")

        #expect(recorder.events.isEmpty)
    }
}
