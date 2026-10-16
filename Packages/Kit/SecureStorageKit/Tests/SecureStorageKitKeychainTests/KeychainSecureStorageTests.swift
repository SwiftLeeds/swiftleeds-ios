import Foundation
import SecureStorageKit
import SecureStorageKitKeychain
import Testing

/// Exercises the real Keychain adapter through its public API. Each test uses a
/// unique service (`SecureStorage.uniqueKeychain`) so runs cannot collide, and
/// `storing(_:at:during:)` removes what it stored.
@Suite struct KeychainSecureStorageTests {
    private let key = SecureStorageKey("auth.token")

    @Test func whenSettingThenReading_shouldReturnTheStoredValue() async throws {
        let storage = SecureStorage.uniqueKeychain
        let token = Data("jwt-abc-123".utf8)

        let stored = try await storage.storing(token, at: key) {
            try await storage.data(key)
        }

        #expect(stored == token)
    }

    @Test func whenSettingAnExistingKey_shouldOverwriteTheValue() async throws {
        let storage = SecureStorage.uniqueKeychain

        let stored = try await storage.storing(Data("first".utf8), at: key) {
            try await storage.set(Data("second".utf8), key)
            return try await storage.data(key)
        }

        #expect(stored == Data("second".utf8))
    }

    @Test func whenReadingAMissingKey_shouldReturnNil() async throws {
        let storage = SecureStorage.uniqueKeychain

        #expect(try await storage.data(SecureStorageKey("does.not.exist")) == nil)
    }

    @Test func whenRemoving_shouldDeleteTheValue() async throws {
        let storage = SecureStorage.uniqueKeychain
        try await storage.set(Data("to-delete".utf8), key)

        try await storage.remove(key)

        #expect(try await storage.data(key) == nil)
    }

    @Test func whenRemovingAMissingKey_shouldNotThrow() async throws {
        let storage = SecureStorage.uniqueKeychain

        try await storage.remove(SecureStorageKey("never.stored"))
    }

    @Test func whenAnotherServiceStoredTheKey_shouldNotReturnItsValue() async throws {
        let mine = SecureStorage.uniqueKeychain
        let theirs = SecureStorage.uniqueKeychain

        let stored = try await theirs.storing(Data("not-yours".utf8), at: key) {
            try await mine.data(key)
        }

        #expect(stored == nil)
    }

    @Test func whenReadingWithAnotherInstanceOfTheSameService_shouldReturnTheStoredValue() async throws {
        let service = KeychainService.unique
        let token = Data("jwt-abc-123".utf8)
        let writer = SecureStorage.keychain(service: service)
        let reader = SecureStorage.keychain(service: service)

        let stored = try await writer.storing(token, at: key) {
            try await reader.data(key)
        }

        #expect(stored == token)
    }
}
