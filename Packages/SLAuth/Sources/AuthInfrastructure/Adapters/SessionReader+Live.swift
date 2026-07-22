import AuthDomain
import Dependencies
import SessionAccess

extension SessionReader: DependencyKey {
    public static var liveValue: Self {
        SessionReader(
            current: {
                @Dependency(\.sessionStore) var sessionStore

                return try? await sessionStore.currentToken().map(Session.init)
            },
            isSignedIn: {
                @Dependency(\.sessionStore) var sessionStore

                let session = try? await sessionStore.currentToken()
                return session != nil
            }
        )
    }
}
