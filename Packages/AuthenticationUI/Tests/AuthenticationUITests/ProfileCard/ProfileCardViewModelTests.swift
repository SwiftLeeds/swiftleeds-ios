import AuthenticationFeature
import AuthenticationUI
import Dependencies
import Foundation
import Testing

@MainActor
@Suite struct ProfileCardViewModelTests {
    @Test func whenProfileLoads_shouldBeLoaded() async {
        let profile = makeProfile()
        await withDependencies {
            $0.fetchProfile = FetchProfile { profile }
        } operation: {
            let sut = ProfileCard.ViewModel(onSignOut: {})

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
            let sut = ProfileCard.ViewModel(onSignOut: {})

            await sut.load()

            #expect(sut.state == .failed)
        }
    }

    @Test func whenSignOutRequested_shouldSignalSignOut() async {
        await confirmation("signals sign out") { signedOut in
            await withDependencies {
                $0.signOut = SignOut {}
            } operation: {
                let sut = ProfileCard.ViewModel(onSignOut: { signedOut() })

                await sut.performSignOut()
            }
        }
    }

    @Test func whenLoading_shouldNotLeak() async {
        let profile = makeProfile()
        weak var weakSUT: ProfileCard.ViewModel?
        await withDependencies {
            $0.fetchProfile = FetchProfile { profile }
        } operation: {
            let sut = ProfileCard.ViewModel(onSignOut: {})
            weakSUT = sut
            await sut.load()
        }
        #expect(weakSUT == nil)
    }

    private func makeProfile() -> Profile {
        Profile(
            name: PersonNameComponents(givenName: "Ada", familyName: "Lovelace"),
            emailAddress: "ada@example.com",
            avatarURL: URL(string: "https://example.com/avatar.png")!,
            qrCodeURL: URL(string: "https://example.com/qr.png")!,
            ticketReference: "ABCD-1"
        )
    }
}
