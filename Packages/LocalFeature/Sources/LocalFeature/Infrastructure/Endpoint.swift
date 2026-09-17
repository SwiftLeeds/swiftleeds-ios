import NetworkKit

/// A request to the SwiftLeeds backend, named in the backend's vocabulary.
package enum Endpoint: HTTPRequestConvertible, Equatable, Hashable, Sendable {
    case local

    package var request: HTTPRequest {
        switch self {
        case .local:
            .get("api/v1/local")
                .appending(headerField: .accept, .application.json)
        }
    }
}
