import Dependencies

package struct SessionMint: Sendable {
    package var establish: @Sendable () -> Void
    package var clear: @Sendable () -> Void
}

extension SessionMint: TestDependencyKey {
    public static var testValue: Self {
        SessionMint(
            establish: { unimplemented("SessionMint.establish is unimplemented") },
            clear: { unimplemented("SessionMint.clear is unimplemented") }
        )
    }
}

extension DependencyValues {
    package var sessionMint: SessionMint {
        get { self[SessionMint.self] }
        set { self[SessionMint.self] = newValue }
    }
}
