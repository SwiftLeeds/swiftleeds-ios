import Dependencies

extension SessionMint: TestDependencyKey {
    public static var testValue: Self {
        SessionMint(
            establish: { unimplemented("SessionMint.establish is unimplemented") },
            clear: { unimplemented("SessionMint.clear is unimplemented") }
        )
    }
}

extension DependencyValues {
    #warning("Rename `sessionStore`")
    package var sessionMint: SessionMint {
        get { self[SessionMint.self] }
        set { self[SessionMint.self] = newValue }
    }
}
