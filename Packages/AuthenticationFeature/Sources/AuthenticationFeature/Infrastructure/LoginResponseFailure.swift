/// Why a login response could not be turned into a session.
enum LoginResponseFailure: Error {
    case invalidCredentials
    case unexpectedStatus(Int)
    case invalidToken(SessionToken.ParsingError)
}

extension SignInError {
    init(_ failure: LoginResponseFailure) {
        switch failure {
        case .invalidCredentials:
            self = .invalidCredentials
        case .unexpectedStatus:
            self = .unknown
        case .invalidToken:
            self = .unknown
        }
    }
}
