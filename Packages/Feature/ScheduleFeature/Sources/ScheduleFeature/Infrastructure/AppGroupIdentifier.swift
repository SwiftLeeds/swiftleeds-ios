/// The app group the app and its extensions share.
public struct AppGroupIdentifier: Equatable, Hashable, Sendable {
    /// The group's identifier.
    fileprivate let identifier: String

    /// Creates an app group identifier.
    /// - Parameter identifier: The identifier, such as
    ///   `group.uk.co.swiftleeds`.
    public init(_ identifier: String) {
        self.identifier = identifier
    }
}

extension String {
    /// Creates a string from an app group identifier.
    /// - Parameter identifier: The identifier to convert.
    public init(_ identifier: AppGroupIdentifier) {
        self = identifier.identifier
    }
}
