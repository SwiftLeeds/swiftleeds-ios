import AuthDomain
import Dependencies
import SessionAccess

extension SessionReader: DependencyKey {
    public static var liveValue: Self {
        SessionReader(
            current: {
                @Dependency(\.sessionStore) var sessionStore

                return try? await sessionStore.currentSession()
            },
            isSignedIn: {
                @Dependency(\.sessionStore) var sessionStore

                let session = try? await sessionStore.currentSession()
                return session != nil
            }
        )
    }
}
