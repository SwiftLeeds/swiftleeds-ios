import Dependencies
import AuthDomain

extension SignIn: DependencyKey {
    public static var liveValue: Self {
        SignIn { emailAddress, ticketReference in
            @Dependency(\.authGateway) var authGateway
            try await authGateway.signIn(emailAddress, ticketReference)
        }
    }
}

extension DependencyValues {
    public var signIn: SignIn {
        get { self[SignIn.self] }
        set { self[SignIn.self] = newValue }
    }
}
