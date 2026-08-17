import Dependencies
import Foundation

struct AttendeeMapper: Sendable {
    var map: @Sendable (Data, HTTPURLResponse) throws(AttendeeResponseFailure) -> Attendee

    init(map: @escaping @Sendable (Data, HTTPURLResponse) throws(AttendeeResponseFailure) -> Attendee) {
        self.map = map
    }
}

extension AttendeeMapper {
    static let live = AttendeeMapper { data, response throws(AttendeeResponseFailure) in
        switch response.statusCode {
        case 200:
            do {
                return try JSONDecoder().decode(AttendeeDTO.self, from: data).attendee()
            } catch {
                throw .couldNotRead(error)
            }
        case 401:
            throw .unauthorized
        default:
            throw .unexpectedStatus(response.statusCode)
        }
    }
}

private enum AttendeeMapperKey: DependencyKey {
    static var liveValue: AttendeeMapper { .live.loggingFailures() }
    /// Mapping is pure, so a test exercises the real thing. Logging still goes to `\.log`, which
    /// defaults to writing nothing.
    static var testValue: AttendeeMapper { liveValue }
}

extension DependencyValues {
    var attendeeMapper: AttendeeMapper {
        get { self[AttendeeMapperKey.self] }
        set { self[AttendeeMapperKey.self] = newValue }
    }
}
