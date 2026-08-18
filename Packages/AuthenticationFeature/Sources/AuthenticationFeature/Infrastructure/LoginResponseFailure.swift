/// Why a login response could not be turned into a session.
///
/// Internal on purpose: `AuthenticationError` is what callers see, and it carries no diagnostic
/// payload. This is what middleware between the two gets to read. It knows nothing about logging;
/// `LoggedLoginFailure` decides how it reads.
enum LoginResponseFailure: Error {
    case invalidCredentials
    case unexpectedStatus(Int)
}

extension AuthenticationError {
    init(_ failure: LoginResponseFailure) {
        switch failure {
        case .invalidCredentials:
            self = .invalidCredentials
        case .unexpectedStatus:
            self = .unknown
        }
    }
}
