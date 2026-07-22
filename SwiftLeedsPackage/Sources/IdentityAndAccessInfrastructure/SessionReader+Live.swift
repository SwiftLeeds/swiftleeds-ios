import Dependencies
import IdentityAndAccessDomain
import SecureStore
import SessionAccess

extension SessionReader: DependencyKey {
    public static var liveValue: Self {
        SessionReader(
            current: {
                @Dependency(\.secureStore) var secureStore
                @Dependency(\.date.now) var now

                guard
                    let data = try? await secureStore.data(.authToken),
                    let raw = String(data: data, encoding: .utf8),
                    let jwt = JWT(raw)
                else {
                    return nil
                }

                return Session()
            },
            isSignedIn: {
                @Dependency(\.secureStore) var secureStore

                let data = try? await secureStore.data(.authToken)
                return data != nil
            }
        )
    }
}
