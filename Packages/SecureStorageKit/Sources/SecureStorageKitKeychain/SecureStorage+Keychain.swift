import Foundation
import SecureStorageKit
import Security

extension SecureStorage {
    /// A `SecureStorage` backed by the Keychain (generic-password items),
    /// scoped to `service`. The Keychain encrypts values at rest.
    ///
    /// Items are stored `WhenUnlockedThisDeviceOnly`, so they are readable only
    /// while the device is unlocked and never travel in a backup.
    public static func keychain(service: KeychainService) -> SecureStorage {
        SecureStorage(
            data: { key in
                var result: CFTypeRef?
                let status = SecItemCopyMatching(
                    KeychainQuery.read(service: service, key: key) as CFDictionary,
                    &result
                )
                switch status {
                case errSecSuccess:
                    return result as? Data
                case errSecItemNotFound:
                    return nil
                default:
                    throw KeychainError(status: status)
                }
            },
            set: { data, key in
                let identity = KeychainQuery.identity(service: service, key: key)
                let updateStatus = SecItemUpdate(
                    identity as CFDictionary,
                    KeychainQuery.update(data: data) as CFDictionary
                )
                switch updateStatus {
                case errSecSuccess:
                    return
                case errSecItemNotFound:
                    let addStatus = SecItemAdd(
                        KeychainQuery.add(service: service, key: key, data: data) as CFDictionary,
                        nil
                    )
                    guard addStatus == errSecSuccess else {
                        throw KeychainError(status: addStatus)
                    }
                default:
                    throw KeychainError(status: updateStatus)
                }
            },
            remove: { key in
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
        )
    }
}
