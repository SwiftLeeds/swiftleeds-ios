/// The app's marketing version, such as `2.1.0`.
public struct AppVersion: Equatable, Hashable, Sendable {
    public enum ParsingError: Error, Equatable, Sendable {
        /// The text is not one to three whole numbers separated by dots.
        case notAVersion(String)
    }

    private static let maximumComponents = 3

    fileprivate let text: String

    /// Creates a version from text in `CFBundleShortVersionString` form, such as `2.1.0`.
    public init(_ text: String) throws(ParsingError) {
        let components = text.split(separator: ".", omittingEmptySubsequences: false)
        guard (1...Self.maximumComponents).contains(components.count),
              components.allSatisfy(Self.isWholeNumber)
        else {
            throw .notAVersion(text)
        }
        self.text = text
    }

    private static func isWholeNumber(_ component: Substring) -> Bool {
        !component.isEmpty && component.allSatisfy(\.isASCIIDigit)
    }
}

extension String {
    package init(_ version: AppVersion) {
        self = version.text
    }
}

private extension Character {
    var isASCIIDigit: Bool {
        isASCII && isNumber
    }
}
