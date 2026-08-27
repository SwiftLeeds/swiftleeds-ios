import Foundation

/// A request to the SwiftLeeds backend, named in the backend's vocabulary.
package enum Endpoint: HTTPRequestConvertible, Equatable, Hashable, Sendable {
    case login(body: Data)
    case profile

    package var request: HTTPRequest {
        switch self {
        case let .login(body):
            .post(Self.loginTicketPath, body: .json(body))
        case .profile:
            .get(Self.loginTicketPath)
        }
    }

    func url(baseURL: URL) -> URL {
        switch self {
        case .login:
            baseURL.appending(path: "api/v1/login/ticket")
        case .profile:
            baseURL.appending(path: "api/v1/login/ticket")
        }
    }

    private static let loginTicketPath: URLPath = "api/v1/login/ticket"
}
