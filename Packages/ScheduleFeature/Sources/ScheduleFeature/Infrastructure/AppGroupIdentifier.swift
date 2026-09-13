/// An app group two processes share.
public struct AppGroupIdentifier: Equatable, Hashable, Sendable {
    fileprivate let identifier: String

    public init(_ identifier: String) {
        self.identifier = identifier
    }
}

extension String {
    public init(_ identifier: AppGroupIdentifier) {
        self = identifier.identifier
    }
}
