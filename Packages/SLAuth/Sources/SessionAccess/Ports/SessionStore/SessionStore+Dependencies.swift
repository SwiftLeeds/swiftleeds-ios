import Dependencies

extension SessionStore: TestDependencyKey {
    public static var testValue: Self {
        SessionStore(
            set: { _ in unimplemented("SessionStore.set is unimplemented") },
            clear: { unimplemented("SessionStore.clear is unimplemented") },
            currentToken: { unimplemented("SessionStore.currentToken is unimplemented", placeholder: nil) },
        )
    }
}

extension DependencyValues {
    package var sessionStore: SessionStore {
        get { self[SessionStore.self] }
        set { self[SessionStore.self] = newValue }
    }
}
