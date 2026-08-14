import Dependencies

package struct SignIn: Sendable {
    private var perform: @Sendable (Credential) async throws -> Void

    private init(perform: @escaping @Sendable (Credential) async throws -> Void) {
        self.perform = perform
    }

    package func callAsFunction(_ credential: Credential) async throws {
        try await perform(credential)
    }
}

extension SignIn {
    package static var live: SignIn {
        SignIn { credential in
            @Dependency(\.authGateway) var authGateway
            @Dependency(\.sessionStore) var sessionStore
            let token = try await authGateway.authenticate(credential)
            try await sessionStore.establish(Session(token))
        }
    }
}
