public struct SecureStoreKey: Equatable, Hashable, Sendable {
    public var stringValue: String { rawValue }

    private let rawValue: String

    public init(_ stringValue: String) {
        self.rawValue = stringValue
    }
}
