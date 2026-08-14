/// The Keychain service namespace under which values are stored.
public struct KeychainService: Hashable, Sendable {
    private let storage: String

    public init(_ value: String) {
        self.storage = value
    }

    fileprivate var stringValue: String { storage }
}

extension String {
    public init(_ service: KeychainService) {
        self = service.stringValue
    }
}
