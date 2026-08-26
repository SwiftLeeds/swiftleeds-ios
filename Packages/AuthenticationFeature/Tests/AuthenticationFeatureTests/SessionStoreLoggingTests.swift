import AuthenticationFeature
import Dependencies
import LogKit
import SecureStorageKit
import Testing

/// Every caller of the store discards its error with `try?`, so the log is the only place a refusal
/// is recorded.
@Suite struct SessionStoreLoggingTests {
    @Test func whenSessionCannotBeStored_shouldLogReasonAtErrorLevel() async throws {
        let session = Session(token: try SessionToken("jwt-abc-123"))

        let event = try #require(await logEvent { try await $0.establish(session) })

        #expect(event.level == .error)
        let reason = try #require(event.fields.first { String($0.name) == "reason" })
        #expect(reason.value == .string("couldNotBuildResponse"))
    }

    @Test func whenSessionCannotBeCleared_shouldLogReasonAtErrorLevel() async throws {
        let event = try #require(await logEvent { try await $0.clear() })

        #expect(event.level == .error)
        let reason = try #require(event.fields.first { String($0.name) == "reason" })
        #expect(reason.value == .string("couldNotBuildResponse"))
    }

    @Test func whenStoredSessionCannotBeRead_shouldLogReasonAtErrorLevel() async throws {
        let event = try #require(await logEvent { _ = try await $0.current() })

        #expect(event.level == .error)
        let reason = try #require(event.fields.first { String($0.name) == "reason" })
        #expect(reason.value == .string("couldNotBuildResponse"))
    }

    @Test func whenStoreRefuses_shouldRethrowRefusal() async throws {
        await withDependencies {
            $0.log = LogRecorder().log
            $0.secureStorage = .failing(with: StubFailure.couldNotBuildResponse)
        } operation: {
            let sut = SessionStore.live.logging()

            await #expect(throws: StubFailure.couldNotBuildResponse) {
                try await sut.clear()
            }
        }
    }

    /// Every other test here builds the decorator itself, so this is the only one that notices if
    /// `liveValue` stops composing it.
    @Test func whenLiveValueStoreRefuses_shouldLogRefusal() async {
        let recorder = LogRecorder()

        await withDependencies {
            $0.log = recorder.log
            $0.secureStorage = .failing(with: StubFailure.couldNotBuildResponse)
        } operation: {
            _ = try? await SessionStore.liveValue.clear()
        }

        #expect(recorder.events.count == 1)
    }

    @Test func whenStoreAccepts_shouldLogOneLinePerOperation() async throws {
        let session = Session(token: try SessionToken("jwt-abc-123"))

        let events = try await acceptedEvents {
            try await $0.establish(session)
            _ = try await $0.current()
            try await $0.clear()
        }

        #expect(events.count == 3)
    }

    @Test func whenSessionIsStored_shouldLogAtInfoLevel() async throws {
        let session = Session(token: try SessionToken("jwt-abc-123"))

        let event = try #require(try await acceptedEvents { try await $0.establish(session) }.first)

        #expect(event.level == .info)
    }

    @Test func whenSessionIsCleared_shouldLogAtInfoLevel() async throws {
        let event = try #require(try await acceptedEvents { try await $0.clear() }.first)

        #expect(event.level == .info)
    }

    /// A read happens on every authenticated request, so it is recorded at the level the platform
    /// drops unless someone is watching.
    @Test func whenStoredSessionIsRead_shouldLogAtDebugLevel() async throws {
        let event = try #require(try await acceptedEvents { _ = try await $0.current() }.first)

        #expect(event.level == .debug)
    }

    /// "Why was the user signed out?" is answered by a read that found nothing, so it must be
    /// filterable on its own rather than sharing the ordinary read's message.
    @Test func whenReadFindsNothing_shouldLogDifferentMessageThanWhenItFindsSession() async throws {
        let session = Session(token: try SessionToken("jwt-abc-123"))

        let foundNothing = try #require(try await acceptedEvents { _ = try await $0.current() }.first)
        let foundSession = try #require(
            try await acceptedEvents {
                try await $0.establish(session)
                _ = try await $0.current()
            }.last
        )

        #expect(foundNothing.message != foundSession.message)
        #expect(foundSession.level == .debug)
    }

    /// Six outcomes, six messages. A destination groups by message, so any pair sharing one could
    /// never be told apart when filtering.
    @Test func whenOutcomesDiffer_shouldLogDifferentMessages() async throws {
        let session = Session(token: try SessionToken("jwt-abc-123"))

        let refused = try await [
            #require(await logEvent { try await $0.establish(session) }),
            #require(await logEvent { try await $0.clear() }),
            #require(await logEvent { _ = try await $0.current() }),
        ].map(\.message)
        let accepted = try await [
            #require(try await acceptedEvents { try await $0.establish(session) }.first),
            #require(try await acceptedEvents { try await $0.clear() }.first),
            #require(try await acceptedEvents { _ = try await $0.current() }.first),
        ].map(\.message)

        #expect(Set(refused + accepted).count == 6)
    }

    private func acceptedEvents(
        _ operation: @escaping @Sendable (SessionStore) async throws -> Void
    ) async throws -> [LogEvent] {
        let recorder = LogRecorder()

        try await withDependencies {
            $0.log = recorder.log
            $0.secureStorage = SecureStorageSpy().secureStorage
        } operation: {
            try await operation(SessionStore.live.logging())
        }

        return recorder.events
    }

    private func logEvent(
        _ operation: @escaping @Sendable (SessionStore) async throws -> Void
    ) async -> LogEvent? {
        let recorder = LogRecorder()

        try? await withDependencies {
            $0.log = recorder.log
            $0.secureStorage = .failing(with: StubFailure.couldNotBuildResponse)
        } operation: {
            try await operation(SessionStore.live.logging())
        }

        return recorder.events.first
    }
}
