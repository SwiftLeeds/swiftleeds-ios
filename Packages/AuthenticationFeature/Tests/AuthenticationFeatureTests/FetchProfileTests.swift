import AuthenticationFeature
import Dependencies
import Foundation
import Testing

@Suite struct FetchProfileTests {
    @Test func whenRepositoryReturnsAttendee_shouldReturnMappedProfile() async throws {
        let attendee = try makeAttendee()

        let profile = try await withDependencies {
            $0.attendeeRepository = .returning(attendee)
        } operation: {
            let sut = FetchProfile.liveValue
            return try await sut()
        }

        #expect(profile == expectedProfile())
    }

    @Test func whenRepositoryFails_shouldRethrowError() async throws {
        await #expect(throws: AttendeeFetchError.unauthorized) {
            try await withDependencies {
                $0.attendeeRepository = .failing(with: .unauthorized)
            } operation: {
                let sut = FetchProfile.liveValue
                return try await sut()
            }
        }
    }

    @Test func whenRepositoryFails_shouldThrowExhaustivelyCatchableError() async {
        var caught: AttendeeFetchError?

        await withDependencies {
            $0.attendeeRepository = .failing(with: .unauthorized)
        } operation: {
            let sut = FetchProfile.liveValue
            do throws(AttendeeFetchError) {
                _ = try await sut()
            } catch {
                caught = error
            }
        }

        #expect(caught == .unauthorized)
    }
}

private func makeAttendee() throws -> Attendee {
    Attendee(
        name: PersonNameComponents(givenName: "Ada", familyName: "Lovelace"),
        emailAddress: try EmailAddress("ada@example.com"),
        avatarURL: AvatarURL(URL(string: "https://example.com/avatar.png")!),
        qrCodeURL: QRCodeURL(URL(string: "https://example.com/qr.png")!),
        ticketReference: try TicketReference("ABCD-12"),
        ticketSlug: try TicketSlug("ti_abc")
    )
}

private func expectedProfile() -> Profile {
    Profile(
        name: PersonNameComponents(givenName: "Ada", familyName: "Lovelace"),
        emailAddress: "ada@example.com",
        avatarURL: URL(string: "https://example.com/avatar.png")!,
        ticketReference: "ABCD-12",
        ticketSlug: try! TicketSlug("ti_abc")
    )
}
