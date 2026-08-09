import Foundation

enum AttendeeMapper {
    static func map(_ data: Data, _ response: HTTPURLResponse) throws(AttendeeFetchError) -> Attendee {
        switch response.statusCode {
        case 200:
            guard let dto = try? JSONDecoder().decode(AttendeeDTO.self, from: data),
                  let attendee = try? dto.attendee()
            else { throw .unknown }
            return attendee
        case 401:
            throw .unauthorized
        default:
            throw .unknown
        }
    }
}
