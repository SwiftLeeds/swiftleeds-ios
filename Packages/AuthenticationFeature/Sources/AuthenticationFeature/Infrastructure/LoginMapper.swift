import Dependencies
import Foundation

package struct LoginMapper: Sendable {
    package var map: @Sendable (Data, HTTPURLResponse) throws(ResponseError) -> SessionToken

    package init(map: @escaping @Sendable (Data, HTTPURLResponse) throws(ResponseError) -> SessionToken) {
        self.map = map
    }
}

extension LoginMapper {
    package static let live = LoginMapper { data, response throws(ResponseError) in
        switch response.statusCode {
        case 200:
            do throws(SessionToken.ParsingError) {
                return try SessionToken(String(decoding: data, as: UTF8.self))
            } catch {
                throw .invalidToken(error)
            }
        case 401:
            throw .invalidCredentials
        default:
            throw .unexpectedStatus(response.statusCode)
        }
    }
}

private enum LoginMapperKey: DependencyKey {
    static var liveValue: LoginMapper { .live.logging() }
    static var testValue: LoginMapper { liveValue }
}

extension DependencyValues {
    var loginMapper: LoginMapper {
        get { self[LoginMapperKey.self] }
        set { self[LoginMapperKey.self] = newValue }
    }
}
