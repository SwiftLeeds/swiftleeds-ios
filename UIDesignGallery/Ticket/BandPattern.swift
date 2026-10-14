/// A texture that marks a role on its band, besides the role's color.
///
/// A texture is a second signal, so a role still reads when color is taken away.
enum BandPattern: Equatable, Hashable, Sendable {
    /// Nothing at all.
    case blank

    /// Slanted lines that run from the lower left to the upper right.
    case diagonalLines

    /// A grid of dots.
    case dots

    /// Level stripes that run across the band.
    case horizontalStripes
}
