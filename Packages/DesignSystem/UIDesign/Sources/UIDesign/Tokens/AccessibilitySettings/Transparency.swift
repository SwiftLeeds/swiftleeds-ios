/// A person's choice about see-through surfaces.
package enum Transparency: Equatable, Hashable, Sendable {
    /// Surfaces may be see-through.
    case standard

    /// Surfaces are solid.
    case reduced
}
