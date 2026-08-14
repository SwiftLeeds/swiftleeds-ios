import Foundation
import SecureStorageKit

actor SecureStorageSpy {
    enum Action: Equatable {
        case data(SecureStorageKey)
        case set(Data, SecureStorageKey)
        case remove(SecureStorageKey)
    }

    private(set) var actions: [Action] = []
    private var stored: Data?

    nonisolated var secureStorage: SecureStorage {
        SecureStorage(
            data: { await self.data($0) },
            set: { await self.set($0, $1) },
            remove: { await self.remove($0) }
        )
    }

    private func data(_ key: SecureStorageKey) -> Data? {
        actions.append(.data(key))
        return stored
    }

    private func set(_ data: Data, _ key: SecureStorageKey) {
        actions.append(.set(data, key))
        stored = data
    }

    private func remove(_ key: SecureStorageKey) {
        actions.append(.remove(key))
        stored = nil
    }
}
