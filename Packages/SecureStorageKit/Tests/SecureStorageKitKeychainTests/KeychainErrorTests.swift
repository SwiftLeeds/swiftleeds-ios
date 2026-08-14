import Foundation
import SecureStorageKitKeychain
import Security
import Testing

/// Maps the statuses a caller can act on. `deviceLocked` matters most: it is
/// transient, so treating it as a storage failure would sign a user out for
/// having a locked phone.
@Suite struct KeychainErrorTests {
    @Test func whenInteractionIsNotAllowed_shouldReportDeviceLocked() {
        #expect(KeychainError(status: errSecInteractionNotAllowed) == .deviceLocked)
    }

    @Test func whenAuthenticationFails_shouldReportAuthenticationFailed() {
        #expect(KeychainError(status: errSecAuthFailed) == .authenticationFailed)
    }

    @Test func whenEntitlementIsMissing_shouldReportMissingEntitlement() {
        #expect(KeychainError(status: errSecMissingEntitlement) == .missingEntitlement)
    }

    @Test func whenStatusIsUnrecognised_shouldKeepItForDiagnosis() {
        #expect(KeychainError(status: errSecDecode) == .unexpected(errSecDecode))
    }

    @Test func whenStatusesDiffer_shouldNotBeEqual() {
        #expect(KeychainError(status: errSecDecode) != KeychainError(status: errSecIO))
    }
}
