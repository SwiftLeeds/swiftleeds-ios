import Dependencies
import Foundation
import SecureStorageKit

extension SessionStore: DependencyKey {
    package static var liveValue: SessionStore {
        live.logging()
    }
}

extension SessionStore {
    package static var live: SessionStore {
        let key = SecureStorageKey("auth.session")
        return SessionStore(
            establish: { session in
                @Dependency(\.secureStorage) var secureStorage
                try await secureStorage.set(JSONEncoder().encode(StoredSessionDTO(session)), key)
            },
            clear: {
                @Dependency(\.secureStorage) var secureStorage
                try await secureStorage.remove(key)
            },
            current: {
                @Dependency(\.secureStorage) var secureStorage
                return try await secureStorage.data(key)
                    .flatMap { try JSONDecoder().decode(StoredSessionDTO.self, from: $0).session }
            },
        )
    }
}
