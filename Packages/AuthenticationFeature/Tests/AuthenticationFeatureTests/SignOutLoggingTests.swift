import AuthenticationFeature
import Dependencies
import LogKit
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

    /// Signing out is rare and it ends a session, so it is worth a line the platform keeps.
    @Test func whenSignOutSucceeds_shouldLogAtNoticeLevel() async throws {
        let event = try #require(await successEvent())

        #expect(event.level == .notice)
    }

    @Test func whenOutcomesDiffer_shouldLogDifferentMessages() async throws {
        let succeeded = try #require(await successEvent())
        let failed = try #require(await failureEvent())

        #expect(succeeded.message != failed.message)
    }

    /// The store names what it did, the use case names what the user got, on both paths.
    @Test func whenStoreAccepts_shouldLogCauseAndOutcome() async {
        let recorder = LogRecorder()

        await withDependencies {
            $0.log = recorder.log
            $0.secureStorage = SecureStorageSpy().secureStorage
            $0.sessionStore = SessionStore.live.logging()
        } operation: {
            let sut = SignOut.liveValue.logging()
            _ = try? await sut()
        }

        #expect(recorder.events.count == 2)
    }

    private func successEvent() async -> LogEvent? {
        let recorder = LogRecorder()

        try? await withDependencies {
            $0.log = recorder.log
            $0.sessionStore = InMemorySessionStore().sessionStore
        } operation: {
            let sut = SignOut.liveValue.logging()
            try await sut()
        }

        return recorder.events.first
    }

    private func failureEvent() async -> LogEvent? {
        let recorder = LogRecorder()

        await withDependencies {
            $0.log = recorder.log
            $0.sessionStore = .failing(with: StubFailure.couldNotBuildResponse)
        } operation: {
            let sut = SignOut.liveValue.logging()
            _ = try? await sut()
        }

        return recorder.events.first
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
