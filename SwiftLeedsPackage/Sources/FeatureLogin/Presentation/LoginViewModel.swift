import Dependencies
import Foundation
import Networking

extension LoginView {
    @Observable
    class ViewModel {
        @ObservationIgnored
        @Dependency(\.logIn) private var logIn

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

//            Task {
//                print("Log in tapped")
//                // 1. Send URL Request with email + token
//                guard let response = try? await URLSession.awaitConnectivity.decode(
//                    Requests.login(
//                        emailAddress: self.emailAddress,
//                        ticketReference: self.ticketReference
//                    ),
//                    dateDecodingStrategy: nil
//                ) else {
//                    print("Response was nil :(")
//                    return
//                }
//
//                print("Response: \(response)")
//
//                self.jwt = response
//            }
//
//            // 2. If success, save token somewhere safe
//
//            // 3. Use token in URLRequest to get user info
        }
    }
}
