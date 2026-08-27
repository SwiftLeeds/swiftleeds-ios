import Foundation

/// A request to the SwiftLeeds backend, named in the backend's vocabulary.
package enum Endpoint: HTTPRequestConvertible, Equatable, Hashable, Sendable {
    case login(body: Data)
    case ticket

    package var request: HTTPRequest {
        switch self {
        case let .login(body):
            .post(Self.loginTicketPath, body: .json(body))
        case .ticket:
            .get(Self.loginTicketPath)
        }
    }

    private static let loginTicketPath: URLPath = "api/v1/login/ticket"
}
