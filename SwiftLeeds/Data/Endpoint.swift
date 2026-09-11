import Foundation
import NetworkKit

enum Endpoint: HTTPRequestConvertible, Equatable, Hashable, Sendable {
    case local
    case schedule(event: UUID?)
    case team

    var request: HTTPRequest {
        switch self {
        case .local:
            .get("api/v1/local")
                .appending(headerField: .accept, .application.json)
        case let .schedule(event):
            .get("api/v2/schedule")
                .appending(headerField: .accept, .application.json)
                .appending(queryItems: Self.queryItems(forEvent: event))
        case .team:
            .get("api/v2/team")
                .appending(headerField: .accept, .application.json)
        }
    }

    private static func queryItems(forEvent event: UUID?) -> [URLQueryItem] {
        guard let event else { return [] }
        return [URLQueryItem(name: "event", value: event.uuidString)]
    }
}
