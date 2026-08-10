import Dependencies

public struct AuthStatus: Sendable {
    public var current: @Sendable () async -> AuthenticationState

    public init(current: @escaping @Sendable () async -> AuthenticationState) {
        self.current = current
    }
}

extension AuthStatus: DependencyKey {
    public static var liveValue: AuthStatus {
        AuthStatus {
            @Dependency(\.sessionStore) var sessionStore
            let session = try? await sessionStore.current()
            return session.map { .signedIn(SignedInProof($0)) } ?? .signedOut
        }
    }

    public static let testValue = AuthStatus(
        current: unimplemented("AuthStatus.current", placeholder: .signedOut)
    )
}

extension DependencyValues {
    public var authStatus: AuthStatus {
        get { self[AuthStatus.self] }
        set { self[AuthStatus.self] = newValue }
    }
}
