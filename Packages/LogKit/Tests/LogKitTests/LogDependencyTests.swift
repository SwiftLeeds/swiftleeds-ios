import Dependencies
import LogKit
import Testing

@Suite struct LogDependencyTests {
    /// The default is `Log.none`, so a test that forgets to override gets silence rather than
    /// real output. That it writes nowhere is covered by `LogCombineTests`.
    @Test func whenNotConfigured_shouldNotTrap() {
        @Dependency(\.log) var log

        log(.critical, "any", "goes nowhere")
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
