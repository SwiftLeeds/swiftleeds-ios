import AuthenticationFeature
import Dependencies
import LogKit
import Testing

/// The cause reaches the log at the mapper or the transport. These assert the outcome the user got.
@Suite struct FetchProfileLoggingTests {
    @Test func whenSessionIsNotAccepted_shouldLogAtNoticeRatherThanError() async throws {
        let event = try #require(await logEvent(whenRepositoryThrows: .unauthorized))

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

    /// A destination groups by message, so two outcomes sharing one message could never be told
    /// apart when filtering.
    @Test func whenOutcomesDiffer_shouldLogDifferentMessages() async throws {
        let unaccepted = try #require(await logEvent(whenRepositoryThrows: .unauthorized))
        let rejected = try #require(await logEvent(whenRepositoryThrows: .invalidResponse))
        let unknown = try #require(await logEvent(whenRepositoryThrows: .unknown))

        #expect(unaccepted.message != rejected.message)
        #expect(rejected.message != unknown.message)
        #expect(unknown.message != unaccepted.message)
    }

    @Test func whenFetchFails_shouldRethrowFailure() async {
        await withDependencies {
            $0.log = LogRecorder().log
            $0.attendeeRepository = .failing(with: .unauthorized)
        } operation: {
            let sut = FetchProfile.liveValue.loggingFailedOutcomes()

            await #expect(throws: AttendeeFetchError.unauthorized) {
                try await sut()
            }
        }
    }

    @Test func whenFetchSucceeds_shouldLogNothing() async throws {
        let recorder = LogRecorder()

        _ = try await withDependencies {
            $0.log = recorder.log
            $0.attendeeRepository = .returning(try Attendee.fixture)
        } operation: {
            let sut = FetchProfile.liveValue.loggingFailedOutcomes()
            return try await sut()
        }

        #expect(recorder.events.isEmpty)
    }

    private func logEvent(whenRepositoryThrows error: AttendeeFetchError) async -> LogEvent? {
        let recorder = LogRecorder()

        await withDependencies {
            $0.log = recorder.log
            $0.attendeeRepository = .failing(with: error)
        } operation: {
            let sut = FetchProfile.liveValue.loggingFailedOutcomes()
            _ = try? await sut()
        }

        return recorder.events.first
    }
}
