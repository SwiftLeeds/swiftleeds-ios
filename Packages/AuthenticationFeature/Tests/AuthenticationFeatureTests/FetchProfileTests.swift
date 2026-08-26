import AuthenticationFeature
import Dependencies
import Foundation
import Testing

@Suite struct FetchProfileTests {
    @Test func whenRepositoryReturnsAttendee_shouldReturnMappedProfile() async throws {
        let attendee = try Attendee.fixture

        let profile = try await withDependencies {
            $0.attendeeRepository = .returning(attendee)
        } operation: {
            let sut = FetchProfile.liveValue
            return try await sut()
        }

        #expect(profile == (try expectedProfile()))
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

private func expectedProfile() throws -> Profile {
    Profile(
        name: PersonNameComponents(givenName: "Ada", familyName: "Lovelace"),
        emailAddress: "ada@example.com",
        avatarURL: try #require(URL(string: "https://example.com/avatar.png")),
        ticketReference: "ABCD-12",
        ticketSlug: try TicketSlug("ti_abc")
    )
}
