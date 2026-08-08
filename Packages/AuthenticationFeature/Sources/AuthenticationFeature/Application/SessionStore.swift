import Dependencies

/// Stores the signed-in session. `current` is `nil` when signed out.
package struct SessionStore: Sendable {
    package var establish: @Sendable (Session) async throws -> Void
    package var clear: @Sendable () async throws -> Void
    package var current: @Sendable () async throws -> Session?
}

extension SessionStore: TestDependencyKey {
    package static let testValue = SessionStore(
        establish: unimplemented("SessionStore.establish"),
        clear: unimplemented("SessionStore.clear"),
        current: unimplemented("SessionStore.current")
    )
}

extension DependencyValues {
    package var sessionStore: SessionStore {
        get { self[SessionStore.self] }
        set { self[SessionStore.self] = newValue }
    }
}
