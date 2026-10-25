import AuthenticationDomain
import Dependencies
import Foundation
import NetworkKit

package struct LoginMapper: Sendable {
    package var map: @Sendable (Data, HTTPURLResponse) throws(ResponseError) -> SessionToken

    package init(map: @escaping @Sendable (Data, HTTPURLResponse) throws(ResponseError) -> SessionToken) {
        self.map = map
    }
}

extension LoginMapper {
    /// The mapper for the backend's answer to a sign-in request.
    ///
    /// A 200 body becomes the session token. A 403 means no ticket matched, and throws
    /// ``ResponseError/invalidCredentials``. Any other status throws
    /// ``ResponseError/unexpectedStatus(_:)``.
    package static let live = LoginMapper { data, response throws(ResponseError) in
        switch response.status {
        case .ok:
            do throws(SessionToken.ParsingError) {
                return try SessionToken(String(decoding: data, as: UTF8.self))
            } catch {
                throw .invalidToken(error)
            }

        case .forbidden:
            throw .invalidCredentials

        default:
            throw .unexpectedStatus(response.status)
        }
    }
}

extension DependencyValues {
    /// The key that stores the login mapper among the dependency values.
    private enum LoginMapperKey: DependencyKey {
        static var liveValue: LoginMapper { .live.logging() }
        /// The live mapper, which tests use as it is.
        static var testValue: LoginMapper { liveValue }
    }

    var loginMapper: LoginMapper {
        get { self[LoginMapperKey.self] }
        set { self[LoginMapperKey.self] = newValue }
    }
}
