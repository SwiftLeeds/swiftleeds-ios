import Dependencies
import Foundation

/// A generic secure key-value store for small, sensitive `Data` payloads.
///
/// The store is agnostic of what it holds — callers own the meaning of each
/// `SecureStorageKey`. A concrete implementation (e.g. Keychain) is supplied by
/// the composition root; consumers depend only on this interface.
public struct SecureStorage: Sendable {
    /// Returns the stored value for `key`, or `nil` when nothing is stored.
    public var data: @Sendable (SecureStorageKey) async throws -> Data?
    /// Stores `data` for `key`, replacing any existing value.
    public var set: @Sendable (Data, SecureStorageKey) async throws -> Void
    /// Removes any value stored for `key`. Removing a missing key is not an error.
    public var remove: @Sendable (SecureStorageKey) async throws -> Void

    public init(
        data: @escaping @Sendable (SecureStorageKey) async throws -> Data?,
        set: @escaping @Sendable (Data, SecureStorageKey) async throws -> Void,
        remove: @escaping @Sendable (SecureStorageKey) async throws -> Void
    ) {
        self.data = data
        self.set = set
        self.remove = remove
    }
}

extension SecureStorage: TestDependencyKey {
    public static var testValue: SecureStorage {
        SecureStorage(
            data: { _ in
                reportIssue("SecureStorage.data is unimplemented")
                return nil
            },
            set: { _, _ in
                reportIssue("SecureStorage.set is unimplemented")
            },
            remove: { _ in
                reportIssue("SecureStorage.remove is unimplemented")
            }
        )
    }
}

extension DependencyValues {
    public var secureStorage: SecureStorage {
        get { self[SecureStorage.self] }
        set { self[SecureStorage.self] = newValue }
    }
}
