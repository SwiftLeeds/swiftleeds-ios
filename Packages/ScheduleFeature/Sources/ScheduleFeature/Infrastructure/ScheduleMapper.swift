import Dependencies
import Foundation
import NetworkKit

struct ScheduleMapper: Sendable {
    enum ResponseError: Error {
        case couldNotDecode(any Error)
        case unexpectedStatus(HTTPStatus)
    }

    var map: @Sendable (Data, HTTPURLResponse) throws(ResponseError) -> Schedule

    init(map: @escaping @Sendable (Data, HTTPURLResponse) throws(ResponseError) -> Schedule) {
        self.map = map
    }
}

extension ScheduleMapper {
    static let live = ScheduleMapper { data, response throws(ResponseError) in
        switch response.status {
        case .ok:
            do {
                return try decoder.decode(Schedule.self, from: data)
            } catch {
                throw .couldNotDecode(error)
            }
        default:
            throw .unexpectedStatus(response.status)
        }
    }

    // Slot dates arrive as ISO8601 and event dates as dd-MM-yyyy, in one payload.
    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            if let date = ISO8601DateFormatter().date(from: dateString) {
                return date
            }

            if let date = dayFormatter.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Expected an ISO8601 or dd-MM-yyyy date, got: \(dateString)"
            )
        }
        return decoder
    }()

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }()
}

private enum ScheduleMapperKey: DependencyKey {
    static var liveValue: ScheduleMapper { .live }
    static var testValue: ScheduleMapper { liveValue }
}

extension DependencyValues {
    var scheduleMapper: ScheduleMapper {
        get { self[ScheduleMapperKey.self] }
        set { self[ScheduleMapperKey.self] = newValue }
    }
}
