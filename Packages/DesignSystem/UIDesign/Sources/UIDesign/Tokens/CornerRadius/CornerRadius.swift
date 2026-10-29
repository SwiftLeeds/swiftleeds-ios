/// The radius of a rounded corner, named for the job the shape does.
public struct CornerRadius: Equatable, Hashable, Sendable {
    /// A job a rounded shape does.
    private enum Role {
        /// A shape that stands for one thing.
        case tile
    }

    /// The job this corner radius does.
    private let role: Role

    /// The corner of a shape that stands for one thing, such as a logo.
    ///
    /// It keeps its radius under every accessibility setting.
    public static let tile = Self(role: .tile)

    /// The level on the raw scale, the same under every accessibility setting.
    package var level: CornerRadiusLevel {
        switch role {
        case .tile: .points8
        }
    }
}
