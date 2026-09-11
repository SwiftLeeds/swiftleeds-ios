import Dependencies
import LogKit
import SponsorsFeature
import Testing

// The cause reaches the log at the mapper or the transport. These assert the outcome the user got.
@Suite struct SponsorsRepositoryLoggingTests {
    // The sponsors load each time the screen appears, so the success sits below the levels the
    // platform writes to disk.
    @Test func whenFetchSucceeds_shouldLogAtInfoLevel() async throws {
        let event = try #require(try await successEvent())

        #expect(event.level == .info)
    }

    // An offline device is expected and the user can retry, so it is not a fault in the app.
    @Test func whenServerCannotBeReached_shouldLogAtNoticeRatherThanError() async throws {
        let event = try #require(await logEvent(whenRepositoryThrows: .couldNotReachServer))

        #expect(event.level == .notice)
    }

    @Test func whenResponseIsRejected_shouldLogAtErrorLevel() async throws {
        let event = try #require(await logEvent(whenRepositoryThrows: .invalidResponse))

        #expect(event.level == .error)
    }

    @Test func whenReasonIsUnknown_shouldLogAtErrorLevel() async throws {
        let event = try #require(await logEvent(whenRepositoryThrows: .unknown))

        #expect(event.level == .error)
    }

    @Test func whenFetchFails_shouldRethrowFailure() async {
        await withDependencies {
            $0.log = LogRecorder().log
        } operation: {
            let sut = SponsorsRepository.failing(with: .couldNotReachServer).logging()

            await #expect(throws: SponsorFetchError.couldNotReachServer) {
                try await sut.fetch()
            }
        }
    }

    // A destination groups by message, so two outcomes sharing one message could never be told
    // apart when filtering.
    @Test func whenOutcomesDiffer_shouldLogDifferentMessages() async throws {
        let messages = try [
            #require(try await successEvent()),
            #require(await logEvent(whenRepositoryThrows: .couldNotReachServer)),
            #require(await logEvent(whenRepositoryThrows: .invalidResponse)),
            #require(await logEvent(whenRepositoryThrows: .unknown)),
        ].map(\.message)

        #expect(Set(messages).count == messages.count)
    }

    @Test func whenLogIsOverriddenAfterBuilding_shouldWriteToTheOverride() async throws {
        let recorder = LogRecorder()
        let sut = SponsorsRepository.returning(Sponsors([.fixture()])).logging()

        _ = try await withDependencies {
            $0.log = recorder.log
        } operation: {
            try await sut.fetch()
        }

        #expect(recorder.events.count == 1)
    }

    private func logEvent(whenRepositoryThrows error: SponsorFetchError) async -> LogEvent? {
        let recorder = LogRecorder()

        await withDependencies {
            $0.log = recorder.log
        } operation: {
            let sut = SponsorsRepository.failing(with: error).logging()
            _ = try? await sut.fetch()
        }

        // Pinned here rather than per test, so a decorator that logs an outcome twice fails
        // everything rather than nothing.
        #expect(recorder.events.count == 1)
        return recorder.events.first
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
