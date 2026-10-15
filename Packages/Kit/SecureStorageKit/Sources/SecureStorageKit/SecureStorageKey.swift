/// A namespaced key identifying a single secured value.
public struct SecureStorageKey: Hashable, Sendable {
    /// The key's name.
    fileprivate let storage: String

    /// Creates a key from its name.
    /// - Parameter value: The key's name, unique within its namespace.
    public init(_ value: String) {
        self.storage = value
    }
}

extension String {
    /// Creates a string from a key.
    /// - Parameter key: The key to convert.
    public init(_ key: SecureStorageKey) {
        self = key.storage
    }
}
