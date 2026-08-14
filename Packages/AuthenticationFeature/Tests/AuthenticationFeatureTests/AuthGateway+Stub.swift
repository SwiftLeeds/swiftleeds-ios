import AuthenticationFeature

extension AuthGateway {
    static func returning(_ token: SessionToken) -> AuthGateway {
        AuthGateway { _ in token }
    }

    static func failing(with error: some Error & Sendable) -> AuthGateway {
        AuthGateway { _ in throw error }
    }
}
