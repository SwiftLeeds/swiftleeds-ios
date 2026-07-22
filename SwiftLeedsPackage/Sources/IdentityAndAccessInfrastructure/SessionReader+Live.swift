import Dependencies
import IdentityAndAccessDomain

extension SessionReader: DependencyKey {
    public static var liveValue: Self {
        SessionReader(
            current: {
                @Dependency(\.secureStore) var secureStore
                @Dependency(\.date.now) var now

                guard
                    let data = try? await secureStore.data(.authToken),
                    let raw = String(data: data, encoding: .utf8),
                    let jwt = JWT(raw),
                    let claims = decodeJWTClaims(jwt),
                    claims.expiresAt > now // Does not belong here -- business logic!
                else {
                    return nil
                }

                return Session(expiresAt: claims.expiresAt)
            },
            isSignedIn: {
                @Dependency(\.secureStore) var secureStore

                let data = try? await secureStore.data(.authToken)
                return data != nil
            }
        )
    }
}
