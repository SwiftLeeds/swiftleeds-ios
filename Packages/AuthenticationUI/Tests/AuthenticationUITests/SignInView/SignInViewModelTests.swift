import AuthenticationFeature
import AuthenticationUI
import Dependencies
import Testing

@MainActor
@Suite struct SignInViewModelTests {
    @Test func whenCredentialsAreValid_shouldAllowSubmit() {
        let sut = SignInView.ViewModel()
        sut.email = "attendee@example.com"
        sut.ticketReference = "ABCD-1"

        #expect(sut.canSubmit)
    }

    @Test func whenEmailIsEmpty_shouldNotAllowSubmit() {
        let sut = SignInView.ViewModel()
        sut.email = ""
        sut.ticketReference = "ABCD-1"

        #expect(!sut.canSubmit)
    }

    @Test func whenTicketReferenceIsMalformed_shouldNotAllowSubmit() {
        let sut = SignInView.ViewModel()
        sut.email = "attendee@example.com"
        sut.ticketReference = "not-a-ref"

        #expect(!sut.canSubmit)
    }

    @Test func whenSignInSucceeds_shouldSignalSignedIn() async {
        await confirmation("signals signed in") { signedIn in
            await withDependencies {
                $0.signIn = SignIn { _ in }
            } operation: {
                let sut = SignInView.ViewModel()
                sut.email = "attendee@example.com"
                sut.ticketReference = "ABCD-1"
                sut.onSignedIn = { signedIn() }

                await sut.submit()

                #expect(sut.phase == .editing)
            }
        }
    }

    @Test func whenSignInFailsWithInvalidCredentials_shouldReportInvalidCredentials() async {
        await withDependencies {
            $0.signIn = SignIn { _ in throw AuthenticationError.invalidCredentials }
        } operation: {
            let sut = SignInView.ViewModel()
            sut.email = "attendee@example.com"
            sut.ticketReference = "ABCD-1"

            await sut.submit()

            #expect(sut.phase == .failed(.invalidCredentials))
        }
    }

    @Test func whenSignInFailsWithUnexpectedError_shouldReportUnknown() async {
        await withDependencies {
            $0.signIn = SignIn { _ in throw UnexpectedError.boom }
        } operation: {
            let sut = SignInView.ViewModel()
            sut.email = "attendee@example.com"
            sut.ticketReference = "ABCD-1"

            await sut.submit()

            #expect(sut.phase == .failed(.unknown))
        }
    }

    @Test func whenErrorDismissed_shouldReturnToEditing() async {
        await withDependencies {
            $0.signIn = SignIn { _ in throw AuthenticationError.unknown }
        } operation: {
            let sut = SignInView.ViewModel()
            sut.email = "attendee@example.com"
            sut.ticketReference = "ABCD-1"
            await sut.submit()

            sut.dismissError()

            #expect(sut.phase == .editing)
        }
    }

    @Test func whenSubmitting_shouldNotLeak() async {
        weak var weakSUT: SignInView.ViewModel?
        await withDependencies {
            $0.signIn = SignIn { _ in }
        } operation: {
            let sut = SignInView.ViewModel()
            weakSUT = sut
            sut.email = "attendee@example.com"
            sut.ticketReference = "ABCD-1"
            await sut.submit()
        }
        #expect(weakSUT == nil)
    }
}

private enum UnexpectedError: Error {
    case boom
}
