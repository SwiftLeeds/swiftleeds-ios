import Dependencies

/// The backend's sign-in check, exchanging a credential for a session token.
package struct AuthGateway: Sendable {
    /// Exchanges a credential for a session token.
    /// - Throws: A ``SignInError`` when the credential is refused, the server
    ///   cannot be reached, or its answer is unexpected.
    package var authenticate: @Sendable (Credential) async throws -> SessionToken

    /// Creates a gateway.
    package init(authenticate: @escaping @Sendable (Credential) async throws -> SessionToken) {
        self.authenticate = authenticate
    }
}

extension AuthGateway: TestDependencyKey {
    /// A stub that reports an issue and throws on every call.
    package static let testValue = AuthGateway(
        authenticate: unimplemented("AuthGateway.authenticate")
    )
}

extension DependencyValues {
    /// The auth gateway the current context uses.
    package var authGateway: AuthGateway {
        get { self[AuthGateway.self] }
        set { self[AuthGateway.self] = newValue }
    }
}
