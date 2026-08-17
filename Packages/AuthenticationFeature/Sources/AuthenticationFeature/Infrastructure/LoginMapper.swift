import Dependencies
import Foundation

struct LoginMapper: Sendable {
    var map: @Sendable (Data, HTTPURLResponse) throws(LoginResponseFailure) -> SessionToken

    init(map: @escaping @Sendable (Data, HTTPURLResponse) throws(LoginResponseFailure) -> SessionToken) {
        self.map = map
    }
}

extension LoginMapper {
    static let live = LoginMapper { data, response throws(LoginResponseFailure) in
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

private enum LoginMapperKey: DependencyKey {
    static var liveValue: LoginMapper { .live }
    static var testValue: LoginMapper { liveValue }
}

extension DependencyValues {
    var loginMapper: LoginMapper {
        get { self[LoginMapperKey.self] }
        set { self[LoginMapperKey.self] = newValue }
    }
}
