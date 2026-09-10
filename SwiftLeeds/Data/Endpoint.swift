import NetworkKit

enum Endpoint: HTTPRequestConvertible, Equatable, Hashable, Sendable {
    case local
    case sponsors
    case team

    var request: HTTPRequest {
        switch self {
        case .local:
            .get("api/v1/local")
                .appending(headerField: .accept, .application.json)
        case .sponsors:
            .get("api/v1/sponsors")
                .appending(headerField: .accept, .application.json)
        case .team:
            .get("api/v2/team")
                .appending(headerField: .accept, .application.json)
        }
    }
}
