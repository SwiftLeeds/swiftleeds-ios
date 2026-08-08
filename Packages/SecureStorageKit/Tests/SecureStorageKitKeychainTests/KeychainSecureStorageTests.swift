import Foundation
import SecureStorageKit
import SecureStorageKitKeychain
import Testing

/// Exercises the real Keychain adapter through its public API. Each test uses a
/// unique service (`SecureStorage.uniqueKeychain`) so runs don't collide, and
/// cleans up after itself.
@Suite struct KeychainSecureStorageTests {
    @Test func whenSettingThenReading_shouldReturnTheStoredValue() async throws {
        let storage = SecureStorage.uniqueKeychain
        let key = SecureStorageKey("auth.token")
        let token = Data("jwt-abc-123".utf8)

        try await storage.set(token, key)
        defer { Task { try? await storage.remove(key) } }

        #expect(try await storage.data(key) == token)
    }

    @Test func whenSettingAnExistingKey_shouldOverwriteTheValue() async throws {
        let storage = SecureStorage.uniqueKeychain
        let key = SecureStorageKey("auth.token")
        defer { Task { try? await storage.remove(key) } }

        try await storage.set(Data("first".utf8), key)
        try await storage.set(Data("second".utf8), key)

        #expect(try await storage.data(key) == Data("second".utf8))
    }

    @Test func whenReadingAMissingKey_shouldReturnNil() async throws {
        let storage = SecureStorage.uniqueKeychain

        #expect(try await storage.data(SecureStorageKey("does.not.exist")) == nil)
    }

    @Test func whenRemoving_shouldDeleteTheValue() async throws {
        let storage = SecureStorage.uniqueKeychain
        let key = SecureStorageKey("auth.token")
        try await storage.set(Data("to-delete".utf8), key)

        try await storage.remove(key)

        #expect(try await storage.data(key) == nil)
    }

    @Test func whenRemovingAMissingKey_shouldNotThrow() async throws {
        let storage = SecureStorage.uniqueKeychain

        try await storage.remove(SecureStorageKey("never.stored"))
    }
}
