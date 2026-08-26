import LogKit

// Named once, so a typo cannot silently create a second category and split a filter in two.
extension LogCategory {
    static let ticket: Self = "ticket"
}
