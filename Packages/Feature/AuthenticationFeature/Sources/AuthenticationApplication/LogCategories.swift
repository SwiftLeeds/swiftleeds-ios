import LogKit

/// The use cases' log categories. Naming them once means a typo cannot silently create a second
/// category and split a filter in two.
extension LogCategory {
    /// Lines from the sign-in and sign-out use cases.
    static let auth: Self = "auth"
    /// Lines from the profile fetch use case.
    static let profile: Self = "profile"
}
