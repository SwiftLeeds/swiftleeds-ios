/// Why a login request never got a response.
enum LoginRequestError: Error {
    case couldNotEncodeRequest(any Error)
    case transportFailed(any Error)
}

extension SignInError {
    init(_ error: LoginRequestError) {
        switch error {
        case .couldNotEncodeRequest:
            self = .unknown
        case .transportFailed:
            self = .couldNotReachServer
        }
    }
}
