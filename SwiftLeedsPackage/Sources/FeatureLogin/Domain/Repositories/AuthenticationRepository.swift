public struct AuthenticationRepository {
    var authenticate: @Sendable (AttendeeCredentials) async throws -> AccessToken
}
