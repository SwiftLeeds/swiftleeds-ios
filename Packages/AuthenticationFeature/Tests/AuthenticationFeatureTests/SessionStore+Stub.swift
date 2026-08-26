import AuthenticationFeature

extension SessionStore {
    static func failing(with error: some Error & Sendable) -> SessionStore {
        SessionStore(
            establish: { _ in throw error },
            clear: { throw error },
            current: { throw error }
        )
    }
}
