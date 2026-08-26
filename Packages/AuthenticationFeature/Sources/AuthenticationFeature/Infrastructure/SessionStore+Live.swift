import Dependencies
import Foundation
import SecureStorageKit

extension SessionStore: DependencyKey {
    package static var liveValue: SessionStore {
        live.loggingFailures()
    }
}

extension SessionStore {
    package static var live: SessionStore {
        let key = SecureStorageKey("auth.session")
        return SessionStore(
            establish: { session in
                @Dependency(\.secureStorage) var secureStorage
                try await secureStorage.set(JSONEncoder().encode(CachedSession(session)), key)
            },
            clear: {
                @Dependency(\.secureStorage) var secureStorage
                try await secureStorage.remove(key)
            },
            current: {
                @Dependency(\.secureStorage) var secureStorage
                return try await secureStorage.data(key)
                    .flatMap { try JSONDecoder().decode(CachedSession.self, from: $0).session }
            }
        )
    }
}
