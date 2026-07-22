import Dependencies
import Foundation
import Networking

extension LoginView {
    @Observable
    class ViewModel {
        @ObservationIgnored
        @Dependency(\.logIn) private var logIn: LogInUseCase

        // TODO: Add continuous parsing through separate func
        var emailAddress: String = ""
        var ticketReference: String = ""

        var jwt: String?

        init() {}

        func logInTapped() {
            Task {
                let token = try await logIn(
                    credentials: AttendeeCredentials(
                        emailAddress: EmailAddress(emailAddress),
                        ticketCredential: TicketCredential(ticketReference)
                    )
                )

                self.jwt = token.stringValue
            }
        }
    }
}
