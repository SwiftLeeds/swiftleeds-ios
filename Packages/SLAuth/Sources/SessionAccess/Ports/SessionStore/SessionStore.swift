package struct SessionStore: Sendable {
    package var set: @Sendable (SessionToken) async throws -> Void
    package var clear: @Sendable () async throws -> Void
    package var currentToken: @Sendable () async throws -> SessionToken? // for the auth-header interceptor

    package init(
        set: @Sendable @escaping (SessionToken) async throws -> Void,
        clear: @Sendable @escaping () async throws -> Void,
        currentToken: @Sendable @escaping () async throws -> SessionToken?
    ) {
        self.set = set
        self.clear = clear
        self.currentToken = currentToken
    }
}
