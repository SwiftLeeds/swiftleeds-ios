/// How a halo's outer edge meets what is behind it.
///
/// The raw value is what the `-halo` launch argument accepts.
enum HaloEdge: String {
    /// The halo stops where it is drawn.
    case hard

    /// The halo blurs outward, so it dissolves into the surface behind it.
    case soft
}
