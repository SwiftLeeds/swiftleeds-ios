import Dependencies

extension SessionStore: TestDependencyKey {
    public static var testValue: Self {
        SessionStore(
            establish: { unimplemented("SessionStore.establish is unimplemented") },
            clear: { unimplemented("SessionStore.clear is unimplemented") }
        )
    }
}

extension DependencyValues {
    #warning("Rename `sessionStore`")
    package var sessionStore: SessionStore {
        get { self[SessionStore.self] }
        set { self[SessionStore.self] = newValue }
    }
}
