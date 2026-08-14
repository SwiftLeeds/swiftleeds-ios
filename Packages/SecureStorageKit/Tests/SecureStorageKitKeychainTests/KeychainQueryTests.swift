import Foundation
import SecureStorageKit
import SecureStorageKitKeychain
import Security
import Testing

/// Pins the two attributes that protect the stored value.
///
/// These are asserted against the query rather than a stored item because they
/// cannot be observed through behaviour: the legacy macOS keychain these tests
/// run against discards `kSecAttrAccessible` entirely, returning it as absent.
/// Changing either one silently weakens security and nothing else would catch
/// it, which is the same reason the storage key is pinned elsewhere.
///
/// Everything else about the queries is covered by `KeychainSecureStorageTests`
/// through the public API.
@Suite struct KeychainQueryTests {
    private let service = KeychainService("uk.co.swiftleeds.tests")
    private let key = SecureStorageKey("auth.session")

    @Test func whenAddingItem_shouldRestrictToThisDeviceWhileUnlocked() {
        let sut = KeychainQuery.add(service: service, key: key, data: Data("jwt".utf8))

        #expect(
            sut[kSecAttrAccessible as String] as? String
                == kSecAttrAccessibleWhenUnlockedThisDeviceOnly as String
        )
    }

    @Test func whenAddingItem_shouldNotMarkItSynchronizable() {
        let sut = KeychainQuery.add(service: service, key: key, data: Data("jwt".utf8))

        #expect(sut[kSecAttrSynchronizable as String] == nil)
    }
}
