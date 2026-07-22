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
            establish: { token in
                @Dependency(\.secureStorage) var secureStorage
                try await secureStorage.set(token.dataValue, .sessionToken)
            },
            clear: {
                @Dependency(\.secureStorage) var secureStorage
                try await secureStorage.remove(.sessionToken)
            },
            currentSession: {
                @Dependency(\.secureStorage) var secureStorage

                guard
                    let data = try await secureStorage.data(.sessionToken),
                    let stringValue = String(data: data, encoding: .utf8),
                    let token = try? SessionToken(stringValue, strategy: .jwt)
                else {
                    return nil
                }

                return Session(token)
            },
        )
    }
}

private extension SessionToken {
    var dataValue: Data {
        Data(self.stringValue.utf8)
    }
}

extension SessionToken.ParseStrategy {
    package static let jwt = SessionToken.ParseStrategy { _ in true }
}
