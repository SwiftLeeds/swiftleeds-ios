import Foundation
import SecureStorageKit
import Security

/// Builds the dictionaries handed to the Keychain.
///
/// Separate from the calls so the attributes can be asserted directly.
package enum KeychainQuery {
    /// Identifies one item, for searching, updating and deleting.
    ///
    /// Carries no value: `SecItemUpdate` rejects a search query containing
    /// `kSecValueData`.
    static func identity(service: KeychainService, key: SecureStorageKey) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: String(service),
            kSecAttrAccount as String: String(key),
        ]
    }

    /// Creates an item readable only while the device is unlocked, and bound to
    /// this device so it is excluded from backups and device transfer.
    package static func add(
        service: KeychainService,
        key: SecureStorageKey,
        data: Data
    ) -> [String: Any] {
        var query = identity(service: service, key: key)
        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        return query
    }

    /// Reads one item's value.
    static func read(service: KeychainService, key: SecureStorageKey) -> [String: Any] {
        var query = identity(service: service, key: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        return query
    }

    /// The attributes passed alongside a search query to change a value.
    static func update(data: Data) -> [String: Any] {
        [kSecValueData as String: data]
    }
}
