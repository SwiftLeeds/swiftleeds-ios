package struct SessionStore: Sendable {
    package var establish: @Sendable (SessionToken) async throws -> Void
    package var clear: @Sendable () async throws -> Void
    package var currentSession: @Sendable () async throws -> Session? // for the auth-header interceptor

    package init(
        establish: @Sendable @escaping (SessionToken) async throws -> Void,
        clear: @Sendable @escaping () async throws -> Void,
        currentSession: @Sendable @escaping () async throws -> Session?
    ) {
        self.establish = establish
        self.clear = clear
        self.currentSession = currentSession
    }
}
