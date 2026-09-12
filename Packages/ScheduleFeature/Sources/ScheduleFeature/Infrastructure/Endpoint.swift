import Foundation
import NetworkKit

/// A request to the SwiftLeeds backend, named in the backend's vocabulary.
enum Endpoint: HTTPRequestConvertible, Equatable, Hashable, Sendable {
    case schedule(event: UUID?)

    var request: HTTPRequest {
        switch self {
        case let .schedule(event):
            .get("api/v2/schedule")
                .appending(headerField: .accept, .application.json)
                .appending(queryItems: Self.queryItems(forEvent: event))
        }
    }

    private static func queryItems(forEvent event: UUID?) -> [URLQueryItem] {
        guard let event else { return [] }
        return [URLQueryItem(name: "event", value: event.uuidString)]
    }
}
