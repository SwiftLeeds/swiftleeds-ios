/// Which gap in an interpolated message a value came from.
///
/// Constructible only inside this package, so a caller cannot mint one and
/// shadow a gap.
public struct GapIndex: Hashable, Sendable {
    /// The gap's position in the message, counted from zero.
    package let value: Int

    /// Creates an index.
    package init(_ value: Int) {
        self.value = value
    }
}
