import Foundation
import SecureStorageKit
import Security

/// Builds the dictionaries handed to the Keychain.
///
/// Separated from the calls themselves so the attributes can be asserted
/// directly. The protection class in particular cannot be checked by storing
/// and reading back: the legacy macOS keychain, which is what unit tests run
/// against, discards `kSecAttrAccessible` entirely.
package enum KeychainQuery {
    /// Identifies one item. Used to search, update and delete.
    ///
    /// Deliberately carries no value and no attributes, because `SecItemUpdate`
    /// requires a search query without `kSecValueData`.
    static func identity(service: KeychainService, key: SecureStorageKey) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: String(service),
            kSecAttrAccount as String: String(key),
        ]
    }

    /// Creates an item, bound to this device and readable only while unlocked.
    ///
    /// `ThisDeviceOnly` keeps the session token out of encrypted backups, so it
    /// cannot ride a restore onto another device. Re-authenticating costs an
    /// email address and a ticket reference, so there is nothing to gain by
    /// letting a bearer credential migrate.
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
