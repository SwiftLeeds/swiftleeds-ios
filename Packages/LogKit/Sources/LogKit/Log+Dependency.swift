import Dependencies

extension Log: TestDependencyKey {
    /// A log that writes nowhere, so a test that does not override the dependency stays silent.
    public static let testValue = Log.none
}

extension DependencyValues {
    /// The log every module writes to.
    ///
    /// LogKit ships no live destination, because only the app knows its subsystem and its salt.
    /// The app builds one at its composition root and sets this. Anything that does not set it
    /// logs nothing.
    public var log: Log {
        get { self[Log.self] }
        set { self[Log.self] = newValue }
    }
}
