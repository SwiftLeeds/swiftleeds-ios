import Dependencies

// TODO: Not sure we need this `AuthenticationRepository`. Why is it returning `AccessToken`? That's for the `tokenStore` to do for example
extension AuthenticationRepository: DependencyKey {
    public static var liveValue: AuthenticationRepository {
        @Dependency(\.authAPI) var authAPI
//        @Dependency(\.tokenStore) var tokenStore // JWTStore? Repo? Is this named correctly?

        return AuthenticationRepository { attendeeCredentials in
            // 1. Fetch JWT from cache

            // 2. If cached token exists + is valid, return

            // 3. Else, try to "log in" (get new access token)
            let token = try await authAPI.logIn(attendeeCredentials)

            // 4. If got new access token, save it
//            try await tokenStore.save(token)

            return token
        }
    }
}

extension DependencyValues {
    var authRepo: AuthenticationRepository {
        get { self[AuthenticationRepository.self] }
        set { self[AuthenticationRepository.self] = newValue }
    }
}
