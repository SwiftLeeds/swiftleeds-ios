import NetworkKit

/// A request to the SwiftLeeds backend, named in the backend's vocabulary.
package enum Endpoint: HTTPRequestConvertible, Equatable, Hashable, Sendable {
    case team

    package var request: HTTPRequest {
        switch self {
        case .team:
            .get("api/v2/team")
                .appending(headerField: .accept, .application.json)
        }
    }
}
