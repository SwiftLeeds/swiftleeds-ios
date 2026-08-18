/// Why a login request never got a response.
enum LoginRequestFailure: Error {
    case couldNotEncodeRequest(any Error)
    case transportFailed(any Error)
}

extension SignInError {
    init(_ failure: LoginRequestFailure) {
        switch failure {
        case .couldNotEncodeRequest:
            self = .unknown
        case .transportFailed:
            self = .couldNotReachServer
        }
    }
}
