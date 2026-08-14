import Foundation
import SecureStorageKit
import Security

/// Owns the Keychain calls for one service.
///
/// An actor because `SecItem` calls are synchronous and blocking, and because
/// writing is a read-modify-write across two calls.
actor KeychainStore {
    private let service: KeychainService

    init(service: KeychainService) {
        self.service = service
    }

    func data(for key: SecureStorageKey) throws -> Data? {
        var result: CFTypeRef?
        let status = SecItemCopyMatching(
            KeychainQuery.read(service: service, key: key) as CFDictionary,
            &result
        )

        switch status {
        case errSecSuccess:
            // An item that exists but is unreadable is a fault, not an absence.
            guard let data = result as? Data else {
                throw KeychainError.unreadableValue
            }
            return data
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainError(status: status)
        }
    }

    func set(_ data: Data, for key: SecureStorageKey) throws {
        switch update(data, for: key) {
        case errSecSuccess:
            return
        case errSecItemNotFound:
            try add(data, for: key)
        case let status:
            throw KeychainError(status: status)
        }
    }

    func remove(_ key: SecureStorageKey) throws {
        let status = SecItemDelete(
            KeychainQuery.identity(service: service, key: key) as CFDictionary
        )

        switch status {
        case errSecSuccess, errSecItemNotFound:
            return
        default:
            throw KeychainError(status: status)
        }
    }

    private func add(_ data: Data, for key: SecureStorageKey) throws {
        let status = SecItemAdd(
            KeychainQuery.add(service: service, key: key, data: data) as CFDictionary,
            nil
        )

        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            // Something wrote between the update and the add. The actor rules
            // that out within this process, leaving other processes.
            guard update(data, for: key) == errSecSuccess else {
                throw KeychainError(status: status)
            }
        default:
            throw KeychainError(status: status)
        }
    }

    private func update(_ data: Data, for key: SecureStorageKey) -> OSStatus {
        SecItemUpdate(
            KeychainQuery.identity(service: service, key: key) as CFDictionary,
            KeychainQuery.update(data: data) as CFDictionary
        )
    }
}
