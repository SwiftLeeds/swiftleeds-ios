import Foundation
import SecureStorageKit
import SecureStorageKitKeychain

extension KeychainService {
    /// A fresh, collision-free service.
    ///
    /// One per test isolates it from every other test and from other runs. Tests run in
    /// parallel, so they cannot share one service and clear it between cases.
    static var unique: KeychainService {
        KeychainService("co.swiftleeds.securestoragekit.tests.\(UUID().uuidString)")
    }
}

extension SecureStorage {
    /// A Keychain-backed store scoped to a fresh service.
    static var uniqueKeychain: SecureStorage {
        .keychain(service: .unique)
    }
}
