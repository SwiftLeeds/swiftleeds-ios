import SecureStorageKit

extension SecureStorage {
    /// Returns a secure storage backed by the Keychain, scoped to `service`.
    ///
    /// The Keychain encrypts values at rest. A value can be read only while the device is unlocked,
    /// and never moves to another device, not even through a backup.
    ///
    /// - Parameter service: The Keychain service that holds every item this storage writes.
    /// - Returns: A secure storage that reads and writes Keychain items for `service`.
    public static func keychain(service: KeychainService) -> SecureStorage {
        let store = KeychainStore(service: service)

        return SecureStorage(
            data: { key in try await store.data(for: key) },
            set: { data, key in try await store.set(data, for: key) },
            remove: { key in try await store.remove(key) },
        )
    }
}
