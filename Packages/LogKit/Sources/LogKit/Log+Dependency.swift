import Dependencies

extension Log: TestDependencyKey {
    /// Writes nothing, so a test only logs when it asks to.
    public static let testValue = Log.none
}

extension DependencyValues {
    public var log: Log {
        get { self[Log.self] }
        set { self[Log.self] = newValue }
    }
}
