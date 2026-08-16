import AuthenticationFeature
import Dependencies
import Testing

@Suite struct SignInTests {
    @Test func whenAuthenticationSucceeds_shouldStoreSession() async throws {
        let store = InMemorySessionStore()

        try await withDependencies {
            $0.authGateway = .returning(SessionToken("jwt-abc-123"))
            $0.sessionStore = store.sessionStore
        } operation: {
            let sut = SignIn.liveValue
            try await sut(credential())
        }

        #expect(await store.stored != nil)
    }

    @Test func whenAuthenticationFails_shouldRethrowFailure() async {
        await withDependencies {
            $0.authGateway = .failing(with: StubError.authenticationFailed)
        } operation: {
            let sut = SignIn.liveValue
            await #expect(throws: StubError.authenticationFailed) {
                try await sut(credential())
            }
        }
    }

    @Test func whenAuthenticationFails_shouldNotStoreSession() async {
        let store = InMemorySessionStore()

        await withDependencies {
            $0.authGateway = .failing(with: StubError.authenticationFailed)
            $0.sessionStore = store.sessionStore
        } operation: {
            let sut = SignIn.liveValue
            _ = try? await sut(credential())
        }

        #expect(await store.stored == nil)
    }
}

private enum StubError: Error, Equatable {
    case authenticationFailed
}

private func credential() throws -> Credential {
    try Credential(
        email: EmailAddress("attendee@example.com"),
        ticketReference: TicketReference("ABCD-12")
    )
}
