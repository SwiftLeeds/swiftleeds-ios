import Dependencies

public struct SignIn: Sendable {
    private var perform: @Sendable (Credential) async throws -> Void

    private init(perform: @escaping @Sendable (Credential) async throws -> Void) {
        self.perform = perform
    }

    public func callAsFunction(_ credential: Credential) async throws {
        try await perform(credential)
    }
}

extension SignIn: DependencyKey {
    public static var liveValue: SignIn {
        SignIn { credential in
            @Dependency(\.authGateway) var authGateway
            @Dependency(\.sessionStore) var sessionStore
            let token = try await authGateway.authenticate(credential)
            try await sessionStore.establish(Session(token: token))
        }
    }

    public static let testValue = SignIn(perform: unimplemented("SignIn"))
}

extension DependencyValues {
    public var signIn: SignIn {
        get { self[SignIn.self] }
        set { self[SignIn.self] = newValue }
    }
}
