public struct SponsorID: Equatable, Hashable, Sendable {
    fileprivate let storage: String

    public init(_ value: String) {
        self.storage = value
    }
}
