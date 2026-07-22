public struct SessionReader: Sendable {
    public var current: @Sendable () async -> Session?
    #warning("Remove `isSignedIn. No longer relevant as existence of `Session` indicates signed-in state")
    public var isSignedIn: @Sendable () async -> Bool

    #warning("Add streamable version later")
    // Could also name `updates`?
    // public var observe: @Sendable () -> AsyncStream<Session?>

    public init(
        current: @Sendable @escaping () async -> Session?,
        isSignedIn: @Sendable @escaping () async -> Bool
    ) {
        self.current = current
        self.isSignedIn = isSignedIn
    }
}
