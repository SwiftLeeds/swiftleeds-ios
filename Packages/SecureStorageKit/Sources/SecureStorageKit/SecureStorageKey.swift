/// A namespaced key identifying a single secured value.
public struct SecureStorageKey: Hashable, Sendable {
    private let storage: String

    public init(_ value: String) {
        self.storage = value
    }

    fileprivate var stringValue: String { storage }
}

extension String {
    public init(_ key: SecureStorageKey) {
        self = key.stringValue
    }
}
