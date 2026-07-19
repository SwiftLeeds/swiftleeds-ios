import Networking
import SwiftUI

public struct LoginView: View {
    @State private var emailAddress: String = ""
    @State private var ticketReference: String = ""

    @State private var jwt: String?

    public init() {}

    public var body: some View {
        List {
            Section(
                content: {
                    Text("JWT: \(jwt ?? "Nil")")
                }
            )

            Section(
                content: {
                    TextField("Email address", text: $emailAddress)
                        .keyboardType(.emailAddress)
                }, header: {
                    Text("Email address")
                }, footer: {
                    Text("The email address you used to buy your ticket")
                        .font(.footnote)
                }
            )

            Section(
                content: {
                    TextField("Ticket Reference", text: $ticketReference)
                }, header: {
                    Text("Ticket Reference")
                }, footer: {
                    Text("It’s in your confirmation email - for example, 'ABCD-1'")
                        .font(.footnote)
                }
            )

            Section {
                Button("Log in") {
                    Task {
                        print("Log in tapped")
                        // 1. Send URL Request with email + token
                        guard let response = try? await URLSession.awaitConnectivity.decode(
                            Requests.login(
                                emailAddress: emailAddress,
                                ticketReference: ticketReference
                            ),
                            dateDecodingStrategy: nil
                        ) else {
                            print("Response was nil :(")
                            return
                        }

                        print("Response: \(response)")

                        self.jwt = response
                    }

                    // 2. If success, save token somewhere safe

                    // 3. Use token in URLRequest to get user info
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
            .navigationTitle("Log in")
    }
}

struct LoginRequest: Codable {
    enum CodingKeys: String, CodingKey {
        case emailAddress = "email"
        case ticketReference = "ticket"
        case event = "event"
    }

    let emailAddress: String
    let ticketReference: String
    let event: String?
}

private extension Requests {
    static func login(
        emailAddress: String,
        ticketReference: String
    ) -> Request<String> {
        let loginRequest = LoginRequest(
            emailAddress: emailAddress,
            ticketReference: ticketReference,
            event: nil
        )

        let encoded = try! JSONEncoder().encode(loginRequest)

        return Request<String>(
            host: host,
            path: "\(apiVersion1)/login/ticket",
            method: .post(encoded),
            headers: [
                "Content-Type": "application/json",
            ]
        )
    }
}
