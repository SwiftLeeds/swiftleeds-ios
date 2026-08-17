import LogKit

/// The app's log categories. Naming them once means a typo cannot silently create a second
/// category and split a filter in two.
extension LogCategory {
    static let push: Self = "push"
}
