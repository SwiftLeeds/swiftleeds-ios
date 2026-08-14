import Foundation

/// A Keychain operation that did not succeed.
///
/// The named cases are the ones a caller can act on. Everything else keeps its
/// `OSStatus` so a failure is still diagnosable.
public enum KeychainError: Error, Equatable {
    /// The item is not accessible in the device's current lock state.
    /// Transient: the same call can succeed later.
    case deviceLocked

    /// The user could not be authenticated for an item that required it.
    case authenticationFailed

    /// The process is not entitled to reach this item.
    case missingEntitlement

    /// An item exists but its value is not `Data`.
    case unreadableValue

    /// Any other status, kept for diagnosis.
    case unexpected(OSStatus)

    package init(status: OSStatus) {
        switch status {
        case errSecInteractionNotAllowed:
            self = .deviceLocked
        case errSecAuthFailed:
            self = .authenticationFailed
        case errSecMissingEntitlement:
            self = .missingEntitlement
        default:
            self = .unexpected(status)
        }
    }
}
