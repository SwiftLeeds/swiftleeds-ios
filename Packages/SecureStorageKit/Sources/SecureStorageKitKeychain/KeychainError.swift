import Foundation

/// An error wrapping a non-success Keychain `OSStatus`.
public struct KeychainError: Error, Equatable {
    public let status: OSStatus

    public init(status: OSStatus) {
        self.status = status
    }
}
