import AuthenticationFeature
import Dependencies
import Foundation
import NetworkKit
import Testing

/// Drives the live composition, stubbing only the transport.
@Suite struct AuthGatewayIntegrationTests {
    @Test func whenServerReturnsJWT_shouldReturnSessionToken() async throws {
        let token = try await withDependencies {
            $0.httpClient = .responding(with: Data("jwt-abc-123".utf8), statusCode: 200)
        } operation: {
            try await AuthGateway.liveValue.authenticate(Credential.fixture)
        }

        #expect(try token == SessionToken("jwt-abc-123"))
    }

    @Test func whenServerReturnsUnauthorized_shouldThrowInvalidCredentials() async throws {
        await #expect(throws: SignInError.invalidCredentials) {
            try await withDependencies {
                $0.httpClient = .responding(with: Data(), statusCode: 401)
            } operation: {
                try await AuthGateway.liveValue.authenticate(Credential.fixture)
            }
        }
    }

    /// A 200 carrying nothing is a server contract violation, not a session.
    @Test func whenServerReturnsEmptyBody_shouldThrowUnknown() async throws {
        await #expect(throws: SignInError.unknown) {
            try await withDependencies {
                $0.httpClient = .responding(with: Data(), statusCode: 200)
            } operation: {
                try await AuthGateway.liveValue.authenticate(Credential.fixture)
            }
        }
    }

    @Test func whenRequestCannotReachServer_shouldThrowCouldNotReachServer() async throws {
        await #expect(throws: SignInError.couldNotReachServer) {
            try await withDependencies {
                $0.httpClient = .failing(with: StubFailure.couldNotBuildResponse)
            } operation: {
                try await AuthGateway.liveValue.authenticate(Credential.fixture)
            }
        }
    }

    @Test func whenServerReturnsOtherStatus_shouldThrowUnknown() async throws {
        await #expect(throws: SignInError.unknown) {
            try await withDependencies {
                $0.httpClient = .responding(with: Data(), statusCode: 500)
            } operation: {
                try await AuthGateway.liveValue.authenticate(Credential.fixture)
            }
        }
    }

    @Test func whenAuthenticating_shouldPOSTCredentialWithNullEvent() async throws {
        let spy = HTTPClientSpy(respondingWith: Data("jwt".utf8), statusCode: 200)

        _ = try await withDependencies {
            $0.httpClient = spy.httpClient
        } operation: {
            try await AuthGateway.liveValue.authenticate(Credential.fixture)
        }

        let request = try #require(await spy.requests.first)
        #expect(request.httpMethod == "POST")
        let body = try JSONSerialization.jsonObject(with: #require(request.httpBody)) as? [String: Any]
        #expect(body?["email"] as? String == "attendee@example.com")
        #expect(body?["ticket"] as? String == "ABCD-12")
        #expect(body?["event"] is NSNull)
    }
    @Test func whenAuthenticating_shouldPOSTJSONToLoginTicketResource() async throws {
        let spy = HTTPClientSpy(respondingWith: Data("jwt".utf8), statusCode: 200)

        _ = try await withDependencies {
            $0.httpClient = spy.httpClient
        } operation: {
            try await AuthGateway.liveValue.authenticate(Credential.fixture)
        }

        let request = try #require(await spy.requests.first)
        #expect(request.url?.path() == "/api/v1/login/ticket")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }

    @Test func whenTransportFails_shouldLogOnlyOnceAcrossChain() async throws {
        let recorder = LogRecorder()

        try? await withDependencies {
            $0.httpClient = .failing(with: StubFailure.couldNotBuildResponse).logging()
            $0.log = recorder.log
        } operation: {
            let sut = AuthGateway.liveValue
            _ = try await sut.authenticate(Credential.fixture)
        }

        #expect(recorder.events.count == 1)
    }

    @Test func whenResponseIsRejected_shouldLogOnlyOnce() async throws {
        let recorder = LogRecorder()

        try? await withDependencies {
            $0.httpClient = .responding(with: Data(), statusCode: 503)
            $0.log = recorder.log
        } operation: {
            let sut = AuthGateway.liveValue
            _ = try await sut.authenticate(Credential.fixture)
        }

        #expect(recorder.events.count == 1)
    }
}
