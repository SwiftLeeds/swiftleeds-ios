import AuthenticationFeature
import Dependencies
import Testing

/// Both call sites move the UI to signed out and discard the error with `try?`, so this line is the
/// only record that the user is not actually signed out.
@Suite struct SignOutLoggingTests {
    @Test func whenSignOutFails_shouldLogAtErrorLevel() async throws {
        let recorder = LogRecorder()

        await withDependencies {
            $0.log = recorder.log
            $0.sessionStore = .failing(with: StubFailure.couldNotBuildResponse)
        } operation: {
            let sut = SignOut.liveValue.logging()
            _ = try? await sut()
        }

        let event = try #require(recorder.events.first)
        #expect(event.level == .error)
    }

    @Test func whenSignOutFails_shouldRethrowFailure() async {
        await withDependencies {
            $0.log = LogRecorder().log
            $0.sessionStore = .failing(with: StubFailure.couldNotBuildResponse)
        } operation: {
            let sut = SignOut.liveValue.logging()

            await #expect(throws: StubFailure.couldNotBuildResponse) {
                try await sut()
            }
        }
    }

    @Test func whenSignOutSucceeds_shouldLogNothing() async throws {
        let recorder = LogRecorder()
        let store = InMemorySessionStore()

        try await withDependencies {
            $0.log = recorder.log
            $0.sessionStore = store.sessionStore
        } operation: {
            let sut = SignOut.liveValue.logging()
            try await sut()
        }

        #expect(recorder.events.isEmpty)
    }

    /// The store names the mechanism, the use case names the outcome. Two seams, two lines, and no
    /// third line from anywhere else.
    @Test func whenStoreRefuses_shouldLogCauseAndOutcome() async {
        let recorder = LogRecorder()

        await withDependencies {
            $0.log = recorder.log
            $0.secureStorage = .failing(with: StubFailure.couldNotBuildResponse)
            $0.sessionStore = SessionStore.live.logging()
        } operation: {
            let sut = SignOut.liveValue.logging()
            _ = try? await sut()
        }

        #expect(recorder.events.count == 2)
    }
}
