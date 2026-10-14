/// A namespaced key identifying a single secured value.
public struct SecureStorageKey: Hashable, Sendable {
    /// The key's name.
    fileprivate let storage: String

    public init(_ value: String) {
        self.storage = value
    }
}

extension String {
    public init(_ key: SecureStorageKey) {
        self = key.storage
    }
}
