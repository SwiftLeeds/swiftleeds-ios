public struct SessionRepository {
    var current: @Sendable () -> AuthenticatedSession?
}
