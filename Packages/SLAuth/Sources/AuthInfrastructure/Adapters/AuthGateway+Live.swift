import AuthDomain
import Dependencies
import SessionAccess

extension AuthGateway: DependencyKey {
    public static var liveValue: Self {
        AuthGateway(
            signIn: { (emailAddress, ticketReference) async throws(SignInError) -> Void in
                @Dependency(\.authAPI) var authAPI
                @Dependency(\.sessionStore) var sessionStore

                do {
                    let token = try await authAPI.signIn(emailAddress.stringValue, ticketReference.stringValue)
                    try await sessionStore.set(SessionToken(token.stringValue))
                } catch {
                    #warning("TODO: Not an accurate error; needs updating")
                    throw SignInError.server
                }
            }
        )
    }
}
