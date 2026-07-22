import Dependencies
import IdentityAndAccessDomain

extension AuthGateway: DependencyKey {
    public static var liveValue: Self {
        AuthGateway(
            signIn: { (emailAddress, ticketReference) async throws(SignInError) -> Void in
                @Dependency(\.authAPI) var authAPI
                @Dependency(\.secureStore) var secureStore

                let token: JWT

                do { token = try await authAPI.signIn(emailAddress.stringValue, ticketReference.stringValue) }
                catch { throw SignInError.server }

                do { try await secureStore.set(token.dataValue, .authToken) }
                catch { throw SignInError.server /* Not accurate, needs updating */ }
            }
        )
    }
}

