import LogKit

/// This kit's log category. Naming it once means a typo cannot silently create a second
/// category and split a filter in two.
extension LogCategory {
    static let network: Self = "network"
}
