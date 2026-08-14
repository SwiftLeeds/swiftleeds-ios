import AuthenticationFeature
import AuthenticationUI
import Dependencies
import Testing

@MainActor
@Suite struct AccountViewModelTests {
    @Test func whenSignedIn_shouldBeSignedIn() async {
        await withDependencies {
            $0.authStatus = AuthStatus { .signedIn(SignedInProof()) }
        } operation: {
            let sut = AccountView.ViewModel()

            await sut.load()

            #expect(sut.state == .signedIn(SignedInProof()))
        }
    }

    @Test func whenSignedOut_shouldBeSignedOut() async {
        await withDependencies {
            $0.authStatus = AuthStatus { .signedOut }
        } operation: {
            let sut = AccountView.ViewModel()

            await sut.load()

            #expect(sut.state == .signedOut(signInRequired: false))
        }
    }

    @Test func whenSignedOutBecauseSignInIsRequired_shouldRequireSignIn() async {
        await withDependencies {
            $0.authStatus = AuthStatus { .signedOut }
        } operation: {
            let sut = AccountView.ViewModel()

            await sut.signedOut(.signInRequired)

            #expect(sut.state == .signedOut(signInRequired: true))
        }
    }

    @Test func whenUserRequestedSignOut_shouldNotRequireSignIn() async {
        await withDependencies {
            $0.authStatus = AuthStatus { .signedOut }
        } operation: {
            let sut = AccountView.ViewModel()

            await sut.signedOut(.userRequested)

            #expect(sut.state == .signedOut(signInRequired: false))
        }
    }

    @Test func whenSignedInAgain_shouldStopRequiringSignIn() async {
        let proof = SignedInProof()
        await withDependencies {
            $0.authStatus = AuthStatus { .signedIn(proof) }
        } operation: {
            let sut = AccountView.ViewModel()
            await sut.signedOut(.signInRequired)

            await sut.signedIn()

            #expect(sut.state == .signedIn(proof))
        }
    }

    @Test func whenLoading_shouldNotLeak() async {
        weak var weakSUT: AccountView.ViewModel?
        await withDependencies {
            $0.authStatus = AuthStatus { .signedOut }
        } operation: {
            let sut = AccountView.ViewModel()
            weakSUT = sut
            await sut.load()
        }
        #expect(weakSUT == nil)
    }
}
