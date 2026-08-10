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

            #expect(sut.state == .signedOut)
        }
    }

    @Test func whenSignInPresented_shouldPresentSignIn() {
        let sut = AccountView.ViewModel()

        sut.presentSignIn()

        #expect(sut.isPresentingSignIn)
    }

    @Test func whenSignInDismissed_shouldNotPresentSignIn() {
        let sut = AccountView.ViewModel()
        sut.presentSignIn()

        sut.dismissSignIn()

        #expect(!sut.isPresentingSignIn)
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
