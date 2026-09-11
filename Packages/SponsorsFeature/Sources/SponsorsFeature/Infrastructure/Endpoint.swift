import NetworkKit

/// A request to the SwiftLeeds backend, named in the backend's vocabulary.
package enum Endpoint: HTTPRequestConvertible, Equatable, Hashable, Sendable {
    case sponsors

    package var request: HTTPRequest {
        switch self {
        case .sponsors:
            .get("api/v1/sponsors")
        }
    }
}
