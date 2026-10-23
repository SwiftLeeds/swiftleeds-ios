import Foundation

/// The address the Contact Us button writes to.
public struct ContactEmail: Equatable, Hashable, Sendable {
    public enum ParsingError: Error, Equatable, Sendable {
        /// The text is not one local part, an `@`, and a domain with a dot.
        case notAnAddress(String)
    }

    /// The number of parts in an address: one local part and one domain, split at the `@`.
    private static let addressPartCount = 2

    package let mailtoURL: URL

    /// Creates a contact address from text such as `hello@conference.example`.
    public init(_ text: String) throws(ParsingError) {
        let parts = text.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == Self.addressPartCount,
            let localPart = parts.first, !localPart.isEmpty,
            let domain = parts.last, Self.isDomain(domain),
            let url = URL(string: "mailto:\(text)")
        else {
            throw .notAnAddress(text)
        }
        mailtoURL = url
    }

    private static func isDomain(_ text: Substring) -> Bool {
        let labels = text.split(separator: ".", omittingEmptySubsequences: false)
        return labels.count > 1 && labels.allSatisfy { !$0.isEmpty }
    }
}
