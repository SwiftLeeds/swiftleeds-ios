import LogKit

/// This feature's log categories. Naming them once means a typo cannot silently create a second
/// category and split a filter in two.
extension LogCategory {
    /// Lines from the sign-in and sign-out use cases.
    static let auth: Self = "auth"
    /// Lines from the session store, which writes to the Keychain.
    static let authStorage: Self = "authStorage"
    /// Lines from the sign-in gateway and its response mapper.
    static let authNetwork: Self = "authNetwork"
    /// Lines from the profile fetch use case.
    static let profile: Self = "profile"
    /// Lines from the attendee response mapper.
    static let profileNetwork: Self = "profileNetwork"
}
