/// Why a login request never got a response.
///
/// Separate from ``LoginResponseFailure`` so each seam owns its own failures: the gateway's
/// decorator logs only these, and passes response failures through already logged.
enum LoginRequestFailure: Error {
    case couldNotEncodeRequest(any Error)
    case transportFailed(any Error)
}

extension AuthenticationError {
    init(_ failure: LoginRequestFailure) {
        switch failure {
        case .couldNotEncodeRequest:
            self = .unknown
        case .transportFailed:
            self = .unknown
        }
    }
}
