import AuthDomain
import Dependencies
import Foundation
import SessionAccess

internal import SecureStorage

extension SecureStorageKey {
    fileprivate static let sessionToken = SecureStorageKey("auth.token")
}

extension SessionStore: DependencyKey {
    package static var liveValue: SessionStore {
        SessionStore(
            set: { token in
                @Dependency(\.secureStorage) var secureStorage
                try await secureStorage.set(token.dataValue, .sessionToken)
            },
            clear: {
                @Dependency(\.secureStorage) var secureStorage
                try await secureStorage.remove(.sessionToken)
            },
            currentToken: {
                @Dependency(\.secureStorage) var secureStorage

                guard
                    let data = try await secureStorage.data(.sessionToken),
                    let str = String(data: data, encoding: .utf8)
                else {
                    return nil
                }

                return SessionToken(str)
            },
        )
    }
}

private extension SessionToken {
    var dataValue: Data {
        Data(self.rawValue.utf8)
    }
}
