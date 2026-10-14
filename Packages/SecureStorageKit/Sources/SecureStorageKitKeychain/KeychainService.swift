/// The Keychain service namespace under which values are stored.
public struct KeychainService: Hashable, Sendable {
    /// The service's name.
    fileprivate let storage: String

    public init(_ value: String) {
        self.storage = value
    }
}

extension String {
    public init(_ service: KeychainService) {
        self = service.storage
    }
}
