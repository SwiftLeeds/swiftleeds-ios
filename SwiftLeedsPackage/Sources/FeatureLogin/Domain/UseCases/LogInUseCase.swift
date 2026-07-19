struct LogInUseCase: Sendable {
    private var handler: @Sendable (_ credentials: AttendeeCredentials) async throws -> AccessToken

    init(
        handler: @Sendable @escaping (_ credentials: AttendeeCredentials) async throws -> AccessToken
    ) {
        self.handler = handler
    }

    func callAsFunction(credentials: AttendeeCredentials) async throws -> AccessToken {
        try await self.handler(credentials)
    }
}
