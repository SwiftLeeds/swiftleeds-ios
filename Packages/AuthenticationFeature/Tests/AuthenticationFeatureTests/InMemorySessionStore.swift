import AuthenticationFeature

actor InMemorySessionStore {
    private(set) var stored: Session?

    init(stored: Session? = nil) {
        self.stored = stored
    }

    nonisolated var sessionStore: SessionStore {
        SessionStore(
            establish: { await self.store($0) },
            clear: { await self.clear() },
            current: { await self.stored }
        )
    }

    private func store(_ session: Session) {
        stored = session
    }

    private func clear() {
        stored = nil
    }
}
