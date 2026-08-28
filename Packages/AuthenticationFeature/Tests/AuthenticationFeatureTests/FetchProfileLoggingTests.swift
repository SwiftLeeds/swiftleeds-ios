import AuthenticationFeature
import Dependencies
import LogKit
import NetworkKit
import Testing

/// The cause reaches the log at the mapper or the transport. These assert the outcome the user got.
@Suite struct FetchProfileLoggingTests {
    @Test func whenSessionIsNotAccepted_shouldLogAtNoticeRatherThanError() async throws {
        let event = try #require(await logEvent(whenRepositoryThrows: .unauthorized))

        #expect(event.level == .notice)
    }

    /// An offline device is expected and the user can retry, so it matches the sign-in side rather
    /// than reporting a fault in the app.
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

    /// A destination groups by message, so two outcomes sharing one message could never be told
    /// apart when filtering.
    @Test func whenOutcomesDiffer_shouldLogDifferentMessages() async throws {
        let messages = try await [
            #require(try await successEvent()),
            #require(await logEvent(whenRepositoryThrows: .unauthorized)),
            #require(await logEvent(whenRepositoryThrows: .couldNotReachServer)),
            #require(await logEvent(whenRepositoryThrows: .invalidResponse)),
            #require(await logEvent(whenRepositoryThrows: .unknown)),
        ].map(\.message)

        #expect(Set(messages).count == messages.count)
    }

    /// The mapper names the cause, the use case names the outcome. Two seams, two lines, and no
    /// third line from anywhere else.
    @Test func whenResponseIsRejected_shouldLogCauseAndOutcome() async throws {
        let recorder = LogRecorder()

        try await withDependencies {
            $0.log = recorder.log
            $0.httpClient = .responding(with: try attendeeJSON(reference: "!!!"), statusCode: 200)
            $0.attendeeRepository = .liveValue
        } operation: {
            let sut = FetchProfile.liveValue.logging()
            _ = try? await sut()
        }

        #expect(recorder.events.count == 2)
    }

    @Test func whenFetchFails_shouldRethrowFailure() async {
        await withDependencies {
            $0.log = LogRecorder().log
            $0.attendeeRepository = .failing(with: .unauthorized)
        } operation: {
            let sut = FetchProfile.liveValue.logging()

            await #expect(throws: AttendeeFetchError.unauthorized) {
                try await sut()
            }
        }
    }

    /// A profile loads each time the card appears, so the success sits below the levels the
    /// platform writes to disk.
    @Test func whenFetchSucceeds_shouldLogAtInfoLevel() async throws {
        let event = try #require(try await successEvent())

        #expect(event.level == .info)
    }

    @Test func whenFetchSucceeds_shouldLogNoAttendeeDetail() async throws {
        let event = try #require(try await successEvent())

        #expect(event.fields.isEmpty)
    }

    private func successEvent() async throws -> LogEvent? {
        let recorder = LogRecorder()

        _ = try await withDependencies {
            $0.log = recorder.log
            $0.attendeeRepository = .returning(try Attendee.fixture)
        } operation: {
            let sut = FetchProfile.liveValue.logging()
            return try await sut()
        }

        return recorder.events.first
    }

    private func logEvent(whenRepositoryThrows error: AttendeeFetchError) async -> LogEvent? {
        let recorder = LogRecorder()

        await withDependencies {
            $0.log = recorder.log
            $0.attendeeRepository = .failing(with: error)
        } operation: {
            let sut = FetchProfile.liveValue.logging()
            _ = try? await sut()
        }

        return recorder.events.first
    }
}
