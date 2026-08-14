import Dependencies

/// Authenticates a credential and returns a session token, throwing if authentication fails.
package struct AuthGateway: Sendable {
    package var authenticate: @Sendable (Credential) async throws -> SessionToken

    package init(authenticate: @escaping @Sendable (Credential) async throws -> SessionToken) {
        self.authenticate = authenticate
    }
}

extension AuthGateway: TestDependencyKey {
    package static let testValue = AuthGateway(
        authenticate: unimplemented("AuthGateway.authenticate")
    )
}

extension DependencyValues {
    package var authGateway: AuthGateway {
        get { self[AuthGateway.self] }
        set { self[AuthGateway.self] = newValue }
    }
}
