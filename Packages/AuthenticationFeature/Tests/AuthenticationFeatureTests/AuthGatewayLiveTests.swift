import AuthenticationFeature
import Dependencies
import Foundation
import Testing

@Suite struct AuthGatewayLiveTests {
    @Test func whenServerReturnsJWT_shouldReturnSessionToken() async throws {
        let token = try await withDependencies {
            $0.httpClient = .responding(with: Data("jwt-abc-123".utf8), statusCode: 200)
        } operation: {
            try await AuthGateway.liveValue.authenticate(credential())
        }

        #expect(token == SessionToken("jwt-abc-123"))
    }

    @Test func whenServerReturnsUnauthorized_shouldThrowInvalidCredentials() async throws {
        await #expect(throws: AuthenticationError.invalidCredentials) {
            try await withDependencies {
                $0.httpClient = .responding(with: Data(), statusCode: 401)
            } operation: {
                try await AuthGateway.liveValue.authenticate(credential())
            }
        }
    }

    @Test func whenServerReturnsOtherStatus_shouldThrowUnknown() async throws {
        await #expect(throws: AuthenticationError.unknown) {
            try await withDependencies {
                $0.httpClient = .responding(with: Data(), statusCode: 500)
            } operation: {
                try await AuthGateway.liveValue.authenticate(credential())
            }
        }
    }

    @Test func whenAuthenticating_shouldPOSTCredentialWithNullEvent() async throws {
        let spy = HTTPClientSpy(respondingWith: Data("jwt".utf8), statusCode: 200)

        _ = try await withDependencies {
            $0.httpClient = spy.httpClient
        } operation: {
            try await AuthGateway.liveValue.authenticate(credential())
        }

        let request = try #require(await spy.requests.first)
        #expect(request.httpMethod == "POST")
        let body = try JSONSerialization.jsonObject(with: #require(request.httpBody)) as? [String: Any]
        #expect(body?["email"] as? String == "attendee@example.com")
        #expect(body?["ticket"] as? String == "ABCD-12")
        #expect(body?["event"] is NSNull)
    }
}

private func credential() throws -> Credential {
    try Credential(
        email: EmailAddress("attendee@example.com"),
        ticketReference: TicketReference("ABCD-12")
    )
}
