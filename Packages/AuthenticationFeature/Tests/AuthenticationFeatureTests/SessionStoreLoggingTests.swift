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

    /// A destination groups by message, so three operations sharing one message could never be told
    /// apart when filtering.
    @Test func whenOperationsFail_shouldLogDifferentMessagePerOperation() async throws {
        let session = Session(token: try SessionToken("jwt-abc-123"))

        let stored = try #require(await logEvent { try await $0.establish(session) })
        let cleared = try #require(await logEvent { try await $0.clear() })
        let read = try #require(await logEvent { _ = try await $0.current() })

        #expect(stored.message != cleared.message)
        #expect(cleared.message != read.message)
        #expect(read.message != stored.message)
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

    @Test func whenStoreAccepts_shouldLogNothing() async throws {
        let recorder = LogRecorder()
        let session = Session(token: try SessionToken("jwt-abc-123"))

        try await withDependencies {
            $0.log = recorder.log
            $0.secureStorage = SecureStorageSpy().secureStorage
        } operation: {
            let sut = SessionStore.live.logging()
            try await sut.establish(session)
            _ = try await sut.current()
            try await sut.clear()
        }

        #expect(recorder.events.isEmpty)
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
