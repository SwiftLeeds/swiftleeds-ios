import LogKit

/// This package's log categories. Naming them once means a typo cannot silently create a second
/// category and split a filter in two.
extension LogCategory {
    static let ticket: Self = "ticket"
}
