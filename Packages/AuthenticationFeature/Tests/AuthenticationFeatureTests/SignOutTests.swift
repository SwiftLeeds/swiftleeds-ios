import AuthenticationFeature
import Dependencies
import Testing

@Suite struct SignOutTests {
    @Test func whenSignedOut_shouldClearStoredSession() async throws {
        let store = InMemorySessionStore(stored: Session(SessionToken("jwt-abc-123")))

        try await withDependencies {
            $0.sessionStore = store.sessionStore
        } operation: {
            let sut = SignOut.live
            try await sut()
        }

        #expect(await store.stored == nil)
    }
}
