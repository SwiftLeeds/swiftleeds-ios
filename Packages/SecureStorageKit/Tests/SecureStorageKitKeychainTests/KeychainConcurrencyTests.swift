import Foundation
import SecureStorageKit
import SecureStorageKitKeychain
import Testing

/// Covers the write path under concurrent callers, which the actor and the
/// duplicate retry protect together. Removing both makes these fail; removing
/// either alone does not.
///
/// They cannot use `storing(_:at:during:)`, because the collision only happens
/// when no item exists yet.
@Suite struct KeychainConcurrencyTests {
    private let key = SecureStorageKey("auth.token")

    @Test func whenWritingConcurrently_shouldStoreOneOfTheWrittenValues() async throws {
        let storage = SecureStorage.uniqueKeychain
        let values = (0..<20).map { Data("value-\($0)".utf8) }

        let stored = try await storage.removingAfterwards(key) {
            try await withThrowingTaskGroup(of: Void.self) { group in
                for value in values {
                    group.addTask { try await storage.set(value, self.key) }
                }
                try await group.waitForAll()
            }
            return try await storage.data(self.key)
        }

        #expect(stored.map(values.contains) == true)
    }

    /// Guards that a read returns a whole value rather than a mixture of two.
    ///
    /// This passes with or without serialisation, because a single
    /// `SecItemCopyMatching` is atomic in the system. It is here to catch a
    /// future read that grows into several calls, not as evidence the actor
    /// works: `whenWritingConcurrently` is what proves that.
    @Test func whenReadingDuringWrites_shouldReturnOneOfTheWrittenValues() async throws {
        let storage = SecureStorage.uniqueKeychain
        let first = Data("first".utf8)
        let second = Data("second".utf8)

        let reads = try await storage.removingAfterwards(key) {
            try await storage.set(first, self.key)

            return try await withThrowingTaskGroup(of: Data?.self, returning: [Data?].self) { group in
                for _ in 0..<20 {
                    group.addTask { try await storage.data(self.key) }
                    group.addTask { try await storage.set(second, self.key); return nil }
                }
                return try await group.reduce(into: []) { $0.append($1) }
            }
        }

        let values = reads.compactMap { $0 }
        #expect(values.allSatisfy { $0 == first || $0 == second })
        #expect(!values.isEmpty)
    }
}
