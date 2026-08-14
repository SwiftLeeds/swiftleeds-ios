import AuthenticationFeature
import Dependencies
import Foundation
import Testing

@Suite struct AttendeeRepositoryLiveTests {
    @Test func whenServerReturnsAttendeeJSON_shouldReturnAttendee() async throws {
        let expected = try expectedAttendee()

        let attendee = try await withDependencies {
            $0.httpClient = .responding(with: attendeeJSON, statusCode: 200)
        } operation: {
            let sut = AttendeeRepository.liveValue
            return try await sut.fetch()
        }

        #expect(attendee == expected)
    }

    @Test func whenServerReturnsUnauthorized_shouldThrowUnauthorized() async throws {
        await #expect(throws: AttendeeFetchError.unauthorized) {
            try await withDependencies {
                $0.httpClient = .responding(with: attendeeJSON, statusCode: 401)
            } operation: {
                let sut = AttendeeRepository.liveValue
                return try await sut.fetch()
            }
        }
    }

    @Test func whenServerReturnsOtherStatus_shouldThrowUnknown() async throws {
        await #expect(throws: AttendeeFetchError.unknown) {
            try await withDependencies {
                $0.httpClient = .responding(with: attendeeJSON, statusCode: 500)
            } operation: {
                let sut = AttendeeRepository.liveValue
                return try await sut.fetch()
            }
        }
    }

    @Test func whenServerReturnsInvalidJSON_shouldThrowUnknown() async throws {
        await #expect(throws: AttendeeFetchError.unknown) {
            try await withDependencies {
                $0.httpClient = .responding(with: Data("not json".utf8), statusCode: 200)
            } operation: {
                let sut = AttendeeRepository.liveValue
                return try await sut.fetch()
            }
        }
    }

    @Test func whenTransportFails_shouldThrowUnknown() async throws {
        await #expect(throws: AttendeeFetchError.unknown) {
            try await withDependencies {
                $0.httpClient = .failing(with: StubError.transport)
            } operation: {
                let sut = AttendeeRepository.liveValue
                return try await sut.fetch()
            }
        }
    }
}

private enum StubError: Error { case transport }

private let attendeeJSON = Data("""
{
    "ticket": {
        "first_name": "Ada",
        "last_name": "Lovelace",
        "email": "ada@example.com",
        "avatar_url": "https://example.com/avatar.png",
        "qr_url": "https://example.com/qr.png",
        "reference": "ABCD-12",
        "slug": "ti_pxqFKr9pPWd6VeYKvMBKpjQ"
    }
}
""".utf8)

private func expectedAttendee() throws -> Attendee {
    Attendee(
        name: PersonNameComponents(givenName: "Ada", familyName: "Lovelace"),
        emailAddress: try EmailAddress("ada@example.com"),
        avatarURL: AvatarURL(URL(string: "https://example.com/avatar.png")!),
        qrCodeURL: QRCodeURL(URL(string: "https://example.com/qr.png")!),
        ticketReference: try TicketReference("ABCD-12"),
        ticketSlug: try TicketSlug("ti_pxqFKr9pPWd6VeYKvMBKpjQ")
    )
}
