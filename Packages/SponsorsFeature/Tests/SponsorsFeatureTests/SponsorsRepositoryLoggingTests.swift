import Dependencies
import LogKit
import SponsorsFeature
import Testing

/// The cause reaches the log at the mapper or the transport. These assert the outcome the user got.
@Suite struct SponsorsRepositoryLoggingTests {
    /// The sponsors load each time the screen appears, so the success sits below the levels the
    /// platform writes to disk.
    @Test func whenFetchSucceeds_shouldLogAtInfoLevel() async throws {
        let event = try #require(try await successEvent())

        #expect(event.level == .info)
    }

    private func successEvent() async throws -> LogEvent? {
        let recorder = LogRecorder()

        _ = try await withDependencies {
            $0.log = recorder.log
        } operation: {
            let sut = SponsorsRepository.returning(Sponsors([.fixture()])).logging()
            return try await sut.fetch()
        }

        // Pinned here rather than per test, so a decorator that logs an outcome twice fails
        // everything rather than nothing.
        #expect(recorder.events.count == 1)
        return recorder.events.first
    }
}
