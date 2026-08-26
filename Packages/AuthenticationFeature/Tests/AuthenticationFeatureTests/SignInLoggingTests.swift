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

    /// Drives the real composition, because the fallback exists for failures the gateway cannot
    /// produce and only the live chain proves one reaches it.
    @Test func whenSessionCannotBeStored_shouldLogAtErrorLevel() async throws {
        let event = try #require(try await storeFailureEvent())

        #expect(event.level == .error)
    }

    /// A destination groups by message, so two outcomes sharing one message could never be told
    /// apart when filtering. The fallback counts as an outcome and must differ too.
    @Test func whenOutcomesDiffer_shouldLogDifferentMessages() async throws {
        let messages = try await [
            #require(try await successEvent()),
            #require(await logEvent(whenGatewayThrows: .invalidCredentials)),
            #require(await logEvent(whenGatewayThrows: .couldNotReachServer)),
            #require(await logEvent(whenGatewayThrows: .unknown)),
            #require(try await storeFailureEvent()),
        ].map(\.message)

        #expect(Set(messages).count == messages.count)
    }

    @Test func whenSignInFails_shouldRethrowFailure() async throws {
        try await withDependencies {
            $0.log = LogRecorder().log
            $0.authGateway = .failing(with: SignInError.invalidCredentials)
            $0.sessionStore = InMemorySessionStore().sessionStore
        } operation: {
            let sut = SignIn.liveValue.logging()

            await #expect(throws: SignInError.invalidCredentials) {
                try await sut(Credential.fixture)
            }
        }
    }

    /// Signing in is rare and it starts a session, so the success is worth a line the platform
    /// keeps. It is what anchors a later question about when the session began.
    @Test func whenSignInSucceeds_shouldLogAtNoticeLevel() async throws {
        let event = try #require(try await successEvent())

        #expect(event.level == .notice)
    }

    @Test func whenSignInSucceeds_shouldLogNoCredential() async throws {
        let event = try #require(try await successEvent())

        #expect(event.fields.isEmpty)
    }

    private func successEvent() async throws -> LogEvent? {
        let recorder = LogRecorder()

        try await withDependencies {
            $0.log = recorder.log
            $0.authGateway = .returning(try SessionToken("jwt-abc-123"))
            $0.sessionStore = InMemorySessionStore().sessionStore
        } operation: {
            let sut = SignIn.liveValue.logging()
            try await sut(Credential.fixture)
        }

        return recorder.events.first
    }

    private func storeFailureEvent() async throws -> LogEvent? {
        let recorder = LogRecorder()

        try await withDependencies {
            $0.log = recorder.log
            $0.authGateway = .returning(try SessionToken("jwt-abc-123"))
            $0.sessionStore = .failing(with: StubFailure.couldNotBuildResponse)
        } operation: {
            let sut = SignIn.liveValue.logging()
            _ = try? await sut(Credential.fixture)
        }

        return recorder.events.first
    }

    private func logEvent(whenGatewayThrows error: SignInError) async throws -> LogEvent? {
        let recorder = LogRecorder()

        try await withDependencies {
            $0.log = recorder.log
            $0.authGateway = .failing(with: error)
            $0.sessionStore = InMemorySessionStore().sessionStore
        } operation: {
            let sut = SignIn.liveValue.logging()
            _ = try? await sut(Credential.fixture)
        }

        return recorder.events.first
    }
}
