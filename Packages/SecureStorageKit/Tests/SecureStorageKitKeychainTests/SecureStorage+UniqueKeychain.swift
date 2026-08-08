import Foundation
import SecureStorageKit
import SecureStorageKitKeychain

extension SecureStorage {
    /// A Keychain-backed store scoped to a fresh, collision-free service, so each
    /// test is isolated from every other run.
    static var uniqueKeychain: SecureStorage {
        .keychain(service: KeychainService("co.swiftleeds.securestoragekit.tests.\(UUID().uuidString)"))
    }
}
