import NetworkKit

enum Endpoint: HTTPRequestConvertible, Equatable, Hashable, Sendable {
    case sponsors

    var request: HTTPRequest {
        switch self {
        case .sponsors:
            .get("api/v1/sponsors")
                .appending(headerField: .accept, .application.json)
        }
    }
}
