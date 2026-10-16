import Foundation
import NetworkKit

/// A request to the SwiftLeeds backend, named in the backend's vocabulary.
enum Endpoint: HTTPRequestConvertible, Equatable, Hashable, Sendable {
    case schedule(ScheduleRequest)

    var request: HTTPRequest {
        switch self {
        case let .schedule(schedule):
            .get("api/v2/schedule")
                .appending(headerField: .accept, .application.json)
                .appending(queryItems: Self.queryItems(for: schedule))
        }
    }

    private static func queryItems(for request: ScheduleRequest) -> [URLQueryItem] {
        switch request {
        case .current:
            []
        case let .event(event):
            [URLQueryItem(name: "event", value: event.uuidString)]
        }
    }
}
