/// The app's marketing version, such as `2.1.0`.
public struct AppVersion: Equatable, Hashable, Sendable {
    /// The reason text cannot become a version.
    public enum ParsingError: Error, Equatable, Sendable {
        /// The text is not one to three whole numbers separated by dots.
        case notAVersion(String)
    }

    /// The most dot-separated numbers a version holds.
    private static let maximumComponents = 3

    /// The version, as given.
    fileprivate let text: String

    /// Creates a version from `CFBundleShortVersionString` text.
    /// - Parameter text: The version text.
    /// - Throws: ``ParsingError/notAVersion(_:)`` if `text` is not one to three
    ///   whole numbers.
    public init(_ text: String) throws(ParsingError) {
        let components = text.split(separator: ".", omittingEmptySubsequences: false)
        guard (1...Self.maximumComponents).contains(components.count),
            components.allSatisfy(Self.isWholeNumber)
        else {
            throw .notAVersion(text)
        }
        self.text = text
    }

    /// Returns whether a component is one or more ASCII digits.
    /// - Parameter component: One dot-separated part of the text.
    private static func isWholeNumber(_ component: Substring) -> Bool {
        !component.isEmpty && component.allSatisfy(\.isASCIIDigit)
    }
}

extension String {
    /// Creates a string from a version.
    /// - Parameter version: The version to convert.
    package init(_ version: AppVersion) {
        self = version.text
    }
}

extension Character {
    /// Whether the character is one of `0` to `9`.
    fileprivate var isASCIIDigit: Bool {
        isASCII && isNumber
    }
}
