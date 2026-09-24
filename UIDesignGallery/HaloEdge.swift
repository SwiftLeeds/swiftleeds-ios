/// How a halo's outer edge meets what is behind it.
///
/// The raw value is what the `-halo` launch argument accepts.
enum HaloEdge: String {
    /// The halo stops where it is drawn.
    case hard

    /// The halo blurs outward, so it dissolves into the surface behind it.
    case soft

    /// The halo holds its color where it meets the subject, then fades out.
    case feathered
}

extension HaloEdge {
    /// Whether the halo draws a crisp stroke against the subject.
    var isCrisp: Bool {
        switch self {
        case .hard: true
        case .soft: false
        case .feathered: true
        }
    }

    /// Whether the halo fades into the surface behind it.
    var fades: Bool {
        switch self {
        case .hard: false
        case .soft: true
        case .feathered: true
        }
    }
}
