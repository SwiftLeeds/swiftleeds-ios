public struct SessionReader: Sendable {
    public var current: @Sendable () async -> Session?

    public init(
        current: @Sendable @escaping () async -> Session?,
    ) {
        self.current = current
    }
}

public extension SessionReader {
    var isSignedIn: Bool {
        get async {
            await self.current() != nil
        }
    }
}
