import AuthenticationFeature
import Dependencies
import LogKit
import Testing

/// The cause reaches the log at the seam that knew it. These assert the outcome the user got.
@Suite struct SignInLoggingTests {
    @Test func whenCredentialsAreRejected_shouldLogAtNoticeRatherThanError() async throws {
        let event = try #require(await logEvent(whenGatewayThrows: .invalidCredentials))

        #expect(event.level == .notice)
    }

    @Test func whenServerCannotBeReached_shouldLogAtNoticeRatherThanError() async throws {
        let event = try #require(await logEvent(whenGatewayThrows: .couldNotReachServer))

        #expect(event.level == .notice)
    }

    @Test func whenReasonIsUnknown_shouldLogAtErrorLevel() async throws {
        let event = try #require(await logEvent(whenGatewayThrows: .unknown))

        #expect(event.level == .error)
    }

    /// The gateway narrows every failure it can produce to `SignInError`, so a failure of any other
    /// type means the server accepted the credentials and the session did not survive.
    @Test func whenSessionCannotBeStored_shouldLogAtErrorLevel() async throws {
        let recorder = LogRecorder()

        try await withDependencies {
            $0.log = recorder.log
            $0.authGateway = .returning(try SessionToken("jwt-abc-123"))
            $0.sessionStore = .failing(with: StubFailure.couldNotBuildResponse)
        } operation: {
            let sut = SignIn.liveValue.loggingFailures()
            _ = try? await sut(Credential.fixture)
        }

        let event = try #require(recorder.events.first)
        #expect(event.level == .error)
    }

    /// A destination groups by message, so two outcomes sharing one message could never be told
    /// apart when filtering.
    @Test func whenOutcomesDiffer_shouldLogDifferentMessages() async throws {
        let rejected = try #require(await logEvent(whenGatewayThrows: .invalidCredentials))
        let unreachable = try #require(await logEvent(whenGatewayThrows: .couldNotReachServer))
        let unknown = try #require(await logEvent(whenGatewayThrows: .unknown))

        #expect(rejected.message != unreachable.message)
        #expect(unreachable.message != unknown.message)
        #expect(unknown.message != rejected.message)
    }

    @Test func whenSignInFails_shouldRethrowFailure() async throws {
        try await withDependencies {
            $0.log = LogRecorder().log
            $0.authGateway = .failing(with: SignInError.invalidCredentials)
            $0.sessionStore = InMemorySessionStore().sessionStore
        } operation: {
            let sut = SignIn.liveValue.loggingFailures()

            await #expect(throws: SignInError.invalidCredentials) {
                try await sut(Credential.fixture)
            }
        }
    }

    @Test func whenSignInSucceeds_shouldLogNothing() async throws {
        let recorder = LogRecorder()

        try await withDependencies {
            $0.log = recorder.log
            $0.authGateway = .returning(try SessionToken("jwt-abc-123"))
            $0.sessionStore = InMemorySessionStore().sessionStore
        } operation: {
            let sut = SignIn.liveValue.loggingFailures()
            try await sut(Credential.fixture)
        }

        #expect(recorder.events.isEmpty)
    }

    private func logEvent(whenGatewayThrows error: SignInError) async throws -> LogEvent? {
        let recorder = LogRecorder()

        try await withDependencies {
            $0.log = recorder.log
            $0.authGateway = .failing(with: error)
            $0.sessionStore = InMemorySessionStore().sessionStore
        } operation: {
            let sut = SignIn.liveValue.loggingFailures()
            _ = try? await sut(Credential.fixture)
        }

        return recorder.events.first
    }
}
