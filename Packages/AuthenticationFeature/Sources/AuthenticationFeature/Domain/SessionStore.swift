import Dependencies

/// The store for the signed-in session.
///
/// The `current` closure returns `nil` when signed out.
package struct SessionStore: Sendable {
    /// Saves a session as the signed-in one.
    /// - Throws: The storage's error when the session cannot be saved.
    package var establish: @Sendable (Session) async throws -> Void

    /// Removes the signed-in session.
    /// - Throws: The storage's error when the session cannot be removed.
    package var clear: @Sendable () async throws -> Void

    /// Returns the signed-in session, or `nil` when signed out.
    /// - Throws: The storage's error when the stored session cannot be read.
    package var current: @Sendable () async throws -> Session?

    /// Creates a store.
    package init(
        establish: @escaping @Sendable (Session) async throws -> Void,
        clear: @escaping @Sendable () async throws -> Void,
        current: @escaping @Sendable () async throws -> Session?,
    ) {
        self.establish = establish
        self.clear = clear
        self.current = current
    }
}

extension SessionStore: TestDependencyKey {
    /// A stub that reports an issue and throws on every call.
    package static let testValue = SessionStore(
        establish: unimplemented("SessionStore.establish"),
        clear: unimplemented("SessionStore.clear"),
        current: unimplemented("SessionStore.current"),
    )
}

extension DependencyValues {
    /// The session store the current context uses.
    package var sessionStore: SessionStore {
        get { self[SessionStore.self] }
        set { self[SessionStore.self] = newValue }
    }
}
