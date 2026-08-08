import Foundation
import SecureStorageKit
import Security

extension SecureStorage {
    /// A `SecureStorage` backed by the Keychain (generic-password items),
    /// scoped to `service`. The Keychain encrypts values at rest.
    public static func keychain(service: KeychainService) -> SecureStorage {
        SecureStorage(
            data: { key in
                var query = baseQuery(service: service, key: key)
                query[kSecReturnData as String] = true
                query[kSecMatchLimit as String] = kSecMatchLimitOne

                var result: CFTypeRef?
                let status = SecItemCopyMatching(query as CFDictionary, &result)
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
                let query = baseQuery(service: service, key: key)
                let updateStatus = SecItemUpdate(
                    query as CFDictionary,
                    [kSecValueData as String: data] as CFDictionary
                )
                switch updateStatus {
                case errSecSuccess:
                    return
                case errSecItemNotFound:
                    var addQuery = query
                    addQuery[kSecValueData as String] = data
                    let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
                    guard addStatus == errSecSuccess else {
                        throw KeychainError(status: addStatus)
                    }
                default:
                    throw KeychainError(status: updateStatus)
                }
            },
            remove: { key in
                let status = SecItemDelete(baseQuery(service: service, key: key) as CFDictionary)
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

private func baseQuery(service: KeychainService, key: SecureStorageKey) -> [String: Any] {
    [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: String(service),
        kSecAttrAccount as String: String(key),
    ]
}
