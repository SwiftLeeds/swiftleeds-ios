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
                    let sessionToken = try SessionToken(token.stringValue, strategy: .jwt)
                    try await sessionStore.establish(sessionToken)
                } catch {
                    #warning("TODO: Not an accurate error; needs updating")
                    throw SignInError.server
                }
            }
        )
    }
}
