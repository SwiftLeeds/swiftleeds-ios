import AuthenticationFeature
import Dependencies
import SecureStorageKit
import Testing

@Suite struct SessionStoreTests {
    @Test func whenSessionEstablished_shouldReadBackSameSession() async throws {
        let session = Session(token: SessionToken("jwt-abc-123"))

        try await withDependencies {
            $0.secureStorage = SecureStorageSpy().secureStorage
        } operation: {
            let sut = SessionStore.liveValue
            try await sut.establish(session)
            let current = try await sut.current()
            #expect(current == session)
        }
    }

    @Test func whenSignedOut_shouldReadNilSession() async throws {
        try await withDependencies {
            $0.secureStorage = SecureStorageSpy().secureStorage
        } operation: {
            let sut = SessionStore.liveValue
            let current = try await sut.current()
            #expect(current == nil)
        }
    }

    @Test func whenCleared_shouldRemoveStoredSession() async throws {
        let spy = SecureStorageSpy()

        try await withDependencies {
            $0.secureStorage = spy.secureStorage
        } operation: {
            let sut = SessionStore.liveValue
            try await sut.clear()
        }

        #expect(await spy.actions == [.remove(SecureStorageKey("auth.session"))])
    }
}
