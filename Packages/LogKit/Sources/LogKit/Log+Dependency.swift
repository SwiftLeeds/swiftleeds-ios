import Dependencies

extension Log: TestDependencyKey {
    /// A log that writes nowhere, so a test that does not override the dependency stays silent.
    public static let testValue = Log.none
}

extension DependencyValues {
    /// The log every module writes to.
    ///
    /// LogKit ships no live value. The app builds a destination at its composition root and sets
    /// this. Code that reads it without setting it logs nothing, and in a debug build reports an
    /// issue on every access.
    public var log: Log {
        get { self[Log.self] }
        set { self[Log.self] = newValue }
    }
}
