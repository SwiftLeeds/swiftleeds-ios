extension LoginMapper {
    /// Why a login response could not be turned into a session.
    enum ResponseError: Error {
        case invalidCredentials
        case unexpectedStatus(Int)
        case invalidToken(SessionToken.ParsingError)
    }
}

extension SignInError {
    init(_ error: LoginMapper.ResponseError) {
        switch error {
        case .invalidCredentials:
            self = .invalidCredentials
        case .unexpectedStatus:
            self = .unknown
        case .invalidToken:
            self = .unknown
        }
    }
}
