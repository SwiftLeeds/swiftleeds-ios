import Foundation
import NetworkKit

/// A request to the SwiftLeeds backend, named in the backend's vocabulary.
package enum Endpoint: HTTPRequestConvertible, Equatable, Hashable, Sendable {
    case login(content: Data)
    case ticket

    package var request: HTTPRequest {
        switch self {
        case let .login(content):
            .post(Self.loginTicketPath, content: .json(content))
        case .ticket:
            .get(Self.loginTicketPath)
        }
    }

    private static let loginTicketPath: URLPath = "api/v1/login/ticket"
}
