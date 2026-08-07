public struct AuthStatus: Sendable {
    public var current: @Sendable () async -> AuthenticationState

    public init(current: @escaping @Sendable () async -> AuthenticationState) {
        self.current = current
    }
}

public enum AuthenticationState {
    case signedIn(SignedIn)
    case signedOut(SignedOut)
}
