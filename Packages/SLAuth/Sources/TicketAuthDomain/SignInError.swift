public enum SignInError: Error, Equatable, Sendable {
    case invalidCredentials
    case network
    case server
}
