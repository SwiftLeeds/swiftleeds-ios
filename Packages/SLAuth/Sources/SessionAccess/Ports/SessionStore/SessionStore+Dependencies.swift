import Dependencies

extension SessionStore: TestDependencyKey {
    public static var testValue: Self {
        SessionStore(
            establish: { _ in unimplemented("SessionStore.establish is unimplemented") },
            clear: { unimplemented("SessionStore.clear is unimplemented") },
            currentSession: { unimplemented("SessionStore.currentSession is unimplemented", placeholder: nil) },
        )
    }
}

extension DependencyValues {
    package var sessionStore: SessionStore {
        get { self[SessionStore.self] }
        set { self[SessionStore.self] = newValue }
    }
}
