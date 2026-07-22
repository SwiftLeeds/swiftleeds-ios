import AuthDomain
import Dependencies
import SessionAccess

internal import SecureStorage

extension SessionReader: DependencyKey {
    public static var liveValue: Self {
        SessionReader(
            current: {
                @Dependency(\.secureStorage) var secureStorage
                @Dependency(\.date.now) var now

                #warning("Should only return session if we have a JWT?")
                guard
                    let data = try? await secureStorage.data(.authToken),
                    let raw = String(data: data, encoding: .utf8),
                    let jwt = JWT(raw)
                else {
                    return nil
                }

                return Session()
            },
            isSignedIn: {
                @Dependency(\.secureStorage) var secureStorage

                let data = try? await secureStorage.data(.authToken)
                return data != nil
            }
        )
    }
}
