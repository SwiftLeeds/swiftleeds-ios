import Foundation

/// A Keychain operation that did not succeed.
///
/// The named cases are the ones a caller can act on. Everything else keeps its
/// `OSStatus` so a failure is still diagnosable.
public enum KeychainError: Error, Equatable {
    /// The device is locked, or the item's protection class does not permit
    /// access right now. Transient: the same call can succeed later, so this is
    /// not a reason to discard the stored value.
    case deviceLocked

    /// The user could not be authenticated for an item that required it.
    case authenticationFailed

    /// The process is not entitled to reach this item. Usually a missing
    /// keychain access group, or an unsigned test process.
    case missingEntitlement

    /// An item exists but its value is not readable as `Data`.
    case unreadableValue

    /// Anything else, kept verbatim rather than flattened away.
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
