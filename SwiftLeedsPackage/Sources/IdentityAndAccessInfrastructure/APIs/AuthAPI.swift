struct AuthAPI {
    var signIn: @Sendable(_ emailAddress: String, _ ticketReference: String) async throws -> JWT
}
