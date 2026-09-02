import AuthenticationFeature
import Dependencies
import Foundation
import NetworkKit
import Testing

/// Drives the live composition, stubbing only the transport.
@Suite struct AttendeeRepositoryIntegrationTests {
    @Test func whenServerReturnsAttendeeJSON_shouldReturnAttendee() async throws {
        let expected = try expectedAttendee()

        let attendee = try await withDependencies {
            $0.authHTTPClient = .responding(with: attendeeJSON(), statusCode: 200)
        } operation: {
            let sut = AttendeeRepository.liveValue
            return try await sut.fetch()
        }

        #expect(attendee == expected)
    }

    @Test func whenServerReturnsUnauthorized_shouldThrowUnauthorized() async throws {
        await #expect(throws: AttendeeFetchError.unauthorized) {
            try await withDependencies {
                $0.authHTTPClient = .responding(with: attendeeJSON(), statusCode: 401)
            } operation: {
                let sut = AttendeeRepository.liveValue
                return try await sut.fetch()
            }
        }
    }

    @Test func whenServerReturnsOtherStatus_shouldThrowUnknown() async throws {
        await #expect(throws: AttendeeFetchError.unknown) {
            try await withDependencies {
                $0.authHTTPClient = .responding(with: attendeeJSON(), statusCode: 500)
            } operation: {
                let sut = AttendeeRepository.liveValue
                return try await sut.fetch()
            }
        }
    }

    @Test func whenServerReturnsInvalidJSON_shouldThrowInvalidResponse() async throws {
        await #expect(throws: AttendeeFetchError.invalidResponse) {
            try await withDependencies {
                $0.authHTTPClient = .responding(with: Data("not json".utf8), statusCode: 200)
            } operation: {
                let sut = AttendeeRepository.liveValue
                return try await sut.fetch()
            }
        }
    }

    @Test func whenServerReturnsUnparsableTicketReference_shouldThrowInvalidResponse() async throws {
        await #expect(throws: AttendeeFetchError.invalidResponse) {
            try await withDependencies {
                $0.authHTTPClient = .responding(with: attendeeJSON(reference: "!!!"), statusCode: 200)
            } operation: {
                let sut = AttendeeRepository.liveValue
                return try await sut.fetch()
            }
        }
    }

    @Test func whenServerReturnsUnparsableEmailAddress_shouldThrowInvalidResponse() async throws {
        await #expect(throws: AttendeeFetchError.invalidResponse) {
            try await withDependencies {
                $0.authHTTPClient = .responding(with: attendeeJSON(email: ""), statusCode: 200)
            } operation: {
                let sut = AttendeeRepository.liveValue
                return try await sut.fetch()
            }
        }
    }

    @Test func whenResponseIsRejected_shouldLogThroughLiveComposition() async throws {
        let recorder = LogRecorder()

        try? await withDependencies {
            $0.authHTTPClient = .responding(with: attendeeJSON(reference: "!!!"), statusCode: 200)
            $0.log = recorder.log
        } operation: {
            let sut = AttendeeRepository.liveValue
            _ = try await sut.fetch()
        }

        #expect(recorder.events.count == 1)
    }

    @Test func whenFetchingAttendee_shouldGETLoginTicketResource() async throws {
        let spy = HTTPClientSpy(respondingWith: attendeeJSON(), statusCode: 200)

        _ = try await withDependencies {
            $0.authHTTPClient = spy.httpClient
        } operation: {
            let sut = AttendeeRepository.liveValue
            return try await sut.fetch()
        }

        let request = try #require(await spy.requests.first)
        #expect(request.httpMethod == "GET")
        #expect(request.url?.path() == "/api/v1/login/ticket")
    }

    /// An offline device is the commonest failure here, and it is not the same as a server the app
    /// cannot make sense of.
    @Test func whenTransportFails_shouldThrowCouldNotReachServer() async throws {
        await #expect(throws: AttendeeFetchError.couldNotReachServer) {
            try await withDependencies {
                $0.authHTTPClient = .failing(with: StubError.transport)
            } operation: {
                let sut = AttendeeRepository.liveValue
                return try await sut.fetch()
            }
        }
    }
}

private enum StubError: Error { case transport }

private func expectedAttendee() throws -> Attendee {
    Attendee(
        name: PersonNameComponents(givenName: "Ada", familyName: "Lovelace"),
        emailAddress: try EmailAddress("ada@example.com"),
        avatarURL: AvatarURL(try #require(URL(string: "https://example.com/avatar.png"))),
        ticketReference: try TicketReference("ABCD-12"),
        ticketSlug: try TicketSlug("ti_pxqFKr9pPWd6VeYKvMBKpjQ")
    )
}
