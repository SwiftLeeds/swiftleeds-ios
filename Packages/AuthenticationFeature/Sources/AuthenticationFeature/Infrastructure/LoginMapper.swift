import Foundation

enum LoginMapper {
    static func map(
        _ data: Data,
        _ response: HTTPURLResponse
    ) throws(LoginResponseFailure) -> SessionToken {
        switch response.statusCode {
        case 200:
            return SessionToken(String(decoding: data, as: UTF8.self))
        case 401:
            throw .invalidCredentials
        default:
            throw .unexpectedStatus(response.statusCode)
        }
    }
}
