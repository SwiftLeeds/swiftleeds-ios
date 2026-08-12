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
