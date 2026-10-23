/// The Keychain service namespace under which values are stored.
public struct KeychainService: Hashable, Sendable {
    /// The service's name.
    fileprivate let storage: String

    /// Creates a service from its name.
    /// - Parameter value: The service's name, by convention in reverse-DNS
    ///   form.
    public init(_ value: String) {
        self.storage = value
    }
}

extension String {
    /// Creates a string from a service.
    /// - Parameter service: The service to convert.
    public init(_ service: KeychainService) {
        self = service.storage
    }
}
