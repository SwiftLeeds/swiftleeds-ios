public struct SessionToken: Equatable, Hashable, Sendable {
    package let rawValue: String

    package init(_ stringValue: String) {
        self.rawValue = stringValue
    }
}
