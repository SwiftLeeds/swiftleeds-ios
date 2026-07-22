import Dependencies
import Foundation
import IdentityAndAccessApplication
import IdentityAndAccessDomain
import SessionAccess

extension SignInView {
    @Observable
    class ViewModel {
        @ObservationIgnored
        @Dependency(\.signIn) private var signIn: SignIn

        @ObservationIgnored
        @Dependency(\.sessionReader) private var sessionReader: SessionReader

        // TODO: Add continuous parsing through separate func
        var emailAddress: String = ""
        var ticketReference: String = ""

        var isSignedIn: Bool = false

        init() {}

        func signInTapped() {
            Task {
                print("Sign in tapped")
                try await signIn(
                    emailAddress: EmailAddress(emailAddress),
                    ticketReference: TicketReference(ticketReference)
                )

                await self.isSignedIn = sessionReader.isSignedIn()
            }
        }
    }
}
