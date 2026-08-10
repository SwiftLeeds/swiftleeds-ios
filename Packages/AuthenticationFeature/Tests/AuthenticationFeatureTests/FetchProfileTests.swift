import AuthenticationFeature
import Dependencies
import Foundation
import Testing

@Suite struct FetchProfileTests {
    @Test func whenRepositoryReturnsAttendee_shouldReturnSameAttendee() async throws {
        let expected = try makeAttendee()

        let attendee = try await withDependencies {
            $0.attendeeRepository = .returning(expected)
        } operation: {
            let sut = FetchProfile.live
            return try await sut()
        }

        #expect(attendee == expected)
    }

    @Test func whenRepositoryFails_shouldRethrowError() async throws {
        await #expect(throws: AttendeeFetchError.unauthorized) {
            try await withDependencies {
                $0.attendeeRepository = .failing(with: .unauthorized)
            } operation: {
                let sut = FetchProfile.live
                return try await sut()
            }
        }
    }
}

private func makeAttendee() throws -> Attendee {
    Attendee(
        name: AttendeeName("Ada Lovelace"),
        emailAddress: try EmailAddress("ada@example.com"),
        avatarURL: AvatarURL(URL(string: "https://example.com/avatar.png")!),
        qrCodeURL: QRCodeURL(URL(string: "https://example.com/qr.png")!),
        ticketReference: try TicketReference("ABCD-12")
    )
}
