import Dependencies
import Foundation

package struct AttendeeMapper: Sendable {
    package var map: @Sendable (Data, HTTPURLResponse) throws(ResponseError) -> Attendee

    package init(map: @escaping @Sendable (Data, HTTPURLResponse) throws(ResponseError) -> Attendee) {
        self.map = map
    }
}

extension AttendeeMapper {
    package static let live = AttendeeMapper { data, response throws(ResponseError) in
        switch response.statusCode {
        case 200:
            let dto: AttendeeDTO
            do {
                dto = try JSONDecoder().decode(AttendeeDTO.self, from: data)
            } catch {
                throw .couldNotDecode(error)
            }
            do throws(AttendeeDTO.FieldError) {
                return try dto.attendee()
            } catch {
                throw .invalidField(error)
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
    static var testValue: AttendeeMapper { liveValue }
}

extension DependencyValues {
    var attendeeMapper: AttendeeMapper {
        get { self[AttendeeMapperKey.self] }
        set { self[AttendeeMapperKey.self] = newValue }
    }
}
