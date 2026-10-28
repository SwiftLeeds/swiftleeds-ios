/// How a person needs things told apart: by color, or without relying on color.
package enum ColorDifferentiation: Equatable, Hashable, Sendable {
    /// Color may tell things apart.
    case standard

    /// Something other than color must tell things apart.
    case withoutColor
}
