import Foundation
import SecureStorageKit

extension SecureStorage {
    /// Stores `data` at `key` for the duration of `body`, then removes it.
    ///
    /// Keeps cleanup out of the test body, so what a test reads as its steps is
    /// only the behaviour under test. Removal still happens when `body` throws,
    /// because a failing test is exactly when a leaked keychain item is least
    /// welcome.
    func storing<T>(
        _ data: Data,
        at key: SecureStorageKey,
        during body: () async throws -> T
    ) async throws -> T {
        try await set(data, key)

        do {
            let result = try await body()
            try await remove(key)
            return result
        } catch {
            try? await remove(key)
            throw error
        }
    }
}
