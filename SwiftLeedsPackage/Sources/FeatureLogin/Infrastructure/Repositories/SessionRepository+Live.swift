import Dependencies

extension SessionRepository: DependencyKey {
    public static var liveValue: Self {
        SessionRepository {
            // TODO: Add other properties to AuthenticatedSession
            AuthenticatedSession()
        }
    }
}

extension DependencyValues {
    var sessionRepo: SessionRepository {
        get { self[SessionRepository.self] }
        set { self[SessionRepository.self] = newValue }
    }
}
