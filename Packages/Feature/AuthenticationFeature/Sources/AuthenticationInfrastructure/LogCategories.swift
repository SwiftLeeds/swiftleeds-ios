import LogKit

/// The infrastructure seams' log categories.
extension LogCategory {
    /// Lines from the session store.
    static let authStorage: Self = "authStorage"
    /// Lines from the sign-in gateway and its response mapper.
    static let authNetwork: Self = "authNetwork"
    /// Lines from the attendee response mapper.
    static let profileNetwork: Self = "profileNetwork"
}
