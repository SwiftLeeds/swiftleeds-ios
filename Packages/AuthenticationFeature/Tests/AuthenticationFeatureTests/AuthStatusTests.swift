import AuthenticationFeature
import Dependencies
import Testing

@Suite struct AuthStatusTests {
    @Test func whenSessionExists_shouldReportSignedIn() async {
        let session = Session(token: SessionToken("jwt-abc-123"))
        let store = InMemorySessionStore(stored: session)

        let state = await withDependencies {
            $0.sessionStore = store.sessionStore
        } operation: {
            await AuthStatus.liveValue.current()
        }

        #expect(state == .signedIn(SignedInProof(session)))
    }

    @Test func whenNoSession_shouldReportSignedOut() async {
        let store = InMemorySessionStore()

        let state = await withDependencies {
            $0.sessionStore = store.sessionStore
        } operation: {
            await AuthStatus.liveValue.current()
        }

        #expect(state == .signedOut)
    }
}
