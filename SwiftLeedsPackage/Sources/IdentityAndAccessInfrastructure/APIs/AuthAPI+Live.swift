import Dependencies
import IdentityAndAccessDomain
import Foundation
import Networking

extension AuthAPI: DependencyKey {
    static var liveValue: AuthAPI { .tito }

    static var tito: AuthAPI {
        AuthAPI(
            signIn: { emailAddress, ticketReference in
//                @Dependency(\.httpClient) var httpClient

                let response = try await URLSession.awaitConnectivity.decode(
                    Requests.login(
                        emailAddress: emailAddress,
                        ticketReference: ticketReference
                    ),
                    dateDecodingStrategy: nil
                )

                guard let token = JWT(response) else {
                    throw SignInError.server
                }

                print(">>> Token: \(token)")

                #warning("Replace all of this claims stuff")
//                guard let claims = decodeJWTClaims(token) else { // Should we not be using this?
//                    throw SignInError.server
//                }
//
//                print(">>> Claims: \(claims)")

                return token
            }
        )
    }
}

extension DependencyValues {
    var authAPI: AuthAPI {
        get { self[AuthAPI.self] }
        set { self[AuthAPI.self] = newValue }
    }
}

// TODO: Move or delete

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
