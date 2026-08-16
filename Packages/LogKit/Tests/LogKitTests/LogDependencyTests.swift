import Dependencies
import LogKit
import Testing

@Suite struct LogDependencyTests {
    @Test func whenNotConfigured_shouldWriteNothing() {
        @Dependency(\.log) var log

        #expect(log.accepts(.critical, "any") == false)
    }

    @Test func whenConfigured_shouldUseTheGivenDestination() {
        let recorder = LogRecorder()

        withDependencies {
            $0.log = recorder.log
        } operation: {
            @Dependency(\.log) var log
            log(.error, "any", "something happened")
        }

        #expect(recorder.events.map(\.message) == ["something happened"])
    }
}
