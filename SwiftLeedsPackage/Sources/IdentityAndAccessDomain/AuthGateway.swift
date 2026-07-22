import Dependencies

public struct AuthGateway: Sendable {
    public var signIn: @Sendable (EmailAddress, TicketReference) async throws(SignInError) -> Void

    public init(
        signIn: @Sendable @escaping (EmailAddress, TicketReference) async throws(SignInError) -> Void
    ) {
        self.signIn = signIn
    }
}

extension AuthGateway: TestDependencyKey {
    public static var testValue: AuthGateway {
        AuthGateway(
            signIn: { (_, _) async throws(SignInError) -> Void in
                unimplemented("AuthGateway.signIn is unimplemented")
            }
        )
    }
}

extension DependencyValues {
    public var authGateway: AuthGateway {
        get { self[AuthGateway.self] }
        set { self[AuthGateway.self] = newValue }
    }
}
