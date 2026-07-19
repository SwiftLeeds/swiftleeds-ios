struct AuthenticationAPI {
    var logIn: @Sendable(_ credentials: AttendeeCredentials) async throws -> AccessToken
}
