import LogKit

/// Internal on purpose: `AuthenticationError` is what callers see, and it carries no diagnostic
/// payload. This is what middleware between the two gets to read.
enum LoginResponseFailure: Error {
    case invalidCredentials
    case unexpectedStatus(Int)
}

extension LoginResponseFailure: LogDescribable {
    var logDescription: String {
        switch self {
        case .invalidCredentials:
            "invalidCredentials"
        case let .unexpectedStatus(code):
            "unexpectedStatus(\(code))"
        }
    }
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
