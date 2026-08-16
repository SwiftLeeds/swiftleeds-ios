import Foundation

enum AttendeeMapper {
    static func map(_ data: Data, _ response: HTTPURLResponse) throws(AttendeeFetchError) -> Attendee {
        switch response.statusCode {
        case 200:
            do {
                return try JSONDecoder().decode(AttendeeDTO.self, from: data).attendee()
            } catch {
                throw .invalidResponse
            }
        case 401:
            throw .unauthorized
        default:
            throw .unknown
        }
    }
}
