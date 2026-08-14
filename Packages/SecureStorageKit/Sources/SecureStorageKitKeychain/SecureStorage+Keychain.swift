import Foundation
import SecureStorageKit

extension SecureStorage {
    /// A `SecureStorage` backed by the Keychain (generic-password items),
    /// scoped to `service`. The Keychain encrypts values at rest.
    ///
    /// Items are stored `WhenUnlockedThisDeviceOnly`, so they are readable only
    /// while the device is unlocked and never travel in a backup.
    public static func keychain(service: KeychainService) -> SecureStorage {
        let store = KeychainStore(service: service)

        return SecureStorage(
            data: { key in try await store.data(for: key) },
            set: { data, key in try await store.set(data, for: key) },
            remove: { key in try await store.remove(key) }
        )
    }
}
