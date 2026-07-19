import Dependencies
import Foundation
import Networking

extension AuthenticationAPI: DependencyKey {
    static var liveValue: AuthenticationAPI {
        .tito
    }

    static var tito: AuthenticationAPI {
        AuthenticationAPI { credentials in
            let jwt = try await URLSession.awaitConnectivity.decode(
                Requests.login(
                    emailAddress: credentials.emailAddress.stringValue,
                    ticketReference: credentials.ticketCredential.stringValue
                ),
                dateDecodingStrategy: nil
            )

            return AccessToken(jwt)
        }

//        @Dependency(\.networkClient) var networkClient
//
//        AuthenticationAPI { credentials in
//            let request = Request(
//                url: "https://tito.example/login/ticket",
//                method: .post,
//                body: [
//                    "email": credentials.email,
//                    "reference": credentials.ticketReference
//                ]
//            )
//
//            let response = try await networkClient.send(request)
//
//            let dto = try response.decode(
//                TitoLoginResponse.self
//            )
//
//            return AccessToken(dto.token)
//        }
    }
}

extension DependencyValues {
    var authAPI: AuthenticationAPI {
        get { self[AuthenticationAPI.self] }
        set { self[AuthenticationAPI.self] = newValue }
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
