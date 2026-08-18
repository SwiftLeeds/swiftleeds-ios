import AuthenticationFeature
import Dependencies
import Foundation
import SecureStorageKit
import Testing

@Suite struct SessionStoreTests {
    /// Storage is an outer ring like any other: a stored token that no longer parses is not a
    /// session, and must not be handed inward as one.
    @Test func whenStoredTokenIsBlank_shouldReportNoSession() async throws {
        let spy = SecureStorageSpy()

        try await withDependencies {
            $0.secureStorage = spy.secureStorage
        } operation: {
            try await spy.secureStorage.set(Data(#"{"token":"  "}"#.utf8), SecureStorageKey("auth.session"))

            #expect(try await SessionStore.liveValue.current() == nil)
        }
    }

    @Test func whenSessionEstablished_shouldReadBackSameSession() async throws {
        let session = Session(token: try SessionToken("jwt-abc-123"))

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
