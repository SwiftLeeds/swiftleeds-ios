import AuthenticationFeature
import AuthenticationUI
import Dependencies
import Foundation
import Testing

@MainActor
@Suite struct ProfileCardViewModelTests {
    @Test func whenProfileLoads_shouldBeLoaded() async throws {
        let profile = try makeProfile()
        await withDependencies {
            $0.fetchProfile = FetchProfile { profile }
        } operation: {
            let sut = ProfileCard.ViewModel(onSignOut: { _ in })

            await sut.load()

            #expect(sut.state == .loaded(profile))
        }
    }

    @Test func whenProfileFetchFails_shouldReportFailure() async {
        await withDependencies {
            $0.fetchProfile = FetchProfile { () async throws(AttendeeFetchError) -> Profile in
                throw .unknown
            }
        } operation: {
            let sut = ProfileCard.ViewModel(onSignOut: { _ in })

            await sut.load()

            #expect(sut.state == .failed)
        }
    }

    @Test func whenResponseIsInvalid_shouldReportFailureWithoutSigningOut() async {
        var captured: SignOutReason?

        await withDependencies {
            $0.fetchProfile = FetchProfile { () async throws(AttendeeFetchError) -> Profile in
                throw .invalidResponse
            }
        } operation: {
            let sut = ProfileCard.ViewModel(onSignOut: { captured = $0 })

            await sut.load()

            #expect(sut.state == .failed)
        }

        #expect(captured == nil)
    }

    /// Losing signal must not cost the user their session.
    @Test func whenServerCannotBeReached_shouldReportFailureWithoutSigningOut() async {
        var captured: SignOutReason?

        await withDependencies {
            $0.fetchProfile = FetchProfile { () async throws(AttendeeFetchError) -> Profile in
                throw .couldNotReachServer
            }
        } operation: {
            let sut = ProfileCard.ViewModel(onSignOut: { captured = $0 })

            await sut.load()

            #expect(sut.state == .failed)
        }

        #expect(captured == nil)
    }

    @Test func whenCredentialsAreRejected_shouldRequireSignIn() async {
        var captured: SignOutReason?

        await withDependencies {
            $0.fetchProfile = FetchProfile { () async throws(AttendeeFetchError) -> Profile in
                throw .unauthorized
            }
        } operation: {
            let sut = ProfileCard.ViewModel(onSignOut: { captured = $0 })

            await sut.load()

            #expect(sut.state != .failed)
        }

        #expect(captured == .signInRequired)
    }

    @Test func whenCredentialsAreRejected_shouldNotSignOutAgain() async {
        await confirmation("signs out", expectedCount: 0) { signedOut in
            await withDependencies {
                $0.fetchProfile = FetchProfile { () async throws(AttendeeFetchError) -> Profile in
                    throw .unauthorized
                }
                $0.signOut = SignOut { signedOut() }
            } operation: {
                let sut = ProfileCard.ViewModel(onSignOut: { _ in })

                await sut.load()
            }
        }
    }

    @Test func whenSignOutRequested_shouldSignalUserRequestedSignOut() async {
        var captured: SignOutReason?

        await confirmation("signs out") { signedOut in
            await withDependencies {
                $0.signOut = SignOut { signedOut() }
            } operation: {
                let sut = ProfileCard.ViewModel(onSignOut: { captured = $0 })

                await sut.signOut()
            }
        }

        #expect(captured == .userRequested)
    }

    @Test func whenLoading_shouldNotLeak() async throws {
        let profile = try makeProfile()
        weak var weakSUT: ProfileCard.ViewModel?
        await withDependencies {
            $0.fetchProfile = FetchProfile { profile }
        } operation: {
            let sut = ProfileCard.ViewModel(onSignOut: { _ in })
            weakSUT = sut
            await sut.load()
        }
        #expect(weakSUT == nil)
    }

    private func makeProfile() throws -> Profile {
        Profile(
            name: PersonNameComponents(givenName: "Ada", familyName: "Lovelace"),
            emailAddress: "ada@example.com",
            avatarURL: try #require(URL(string: "https://example.com/avatar.png")),
            ticketReference: "ABCD-1",
            ticketSlug: try TicketSlug("ti_abc")
        )
    }
}
