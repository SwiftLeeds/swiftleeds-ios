import Dependencies

extension Log: TestDependencyKey {
    public static let testValue = Log.none
}

extension DependencyValues {
    public var log: Log {
        get { self[Log.self] }
        set { self[Log.self] = newValue }
    }
}
