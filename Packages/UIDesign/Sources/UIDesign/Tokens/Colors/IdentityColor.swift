import SwiftUI

/// The colors that tell one person from another.
public extension ShapeStyle where Self == Color {
    /// The color standing for a person, the same one every time.
    ///
    /// Every color is one of Apple's own, so it adapts to the appearance and to Increase Contrast
    /// with no tuning of ours, and carries white text the way Apple's do.
    ///
    /// A filled circle behind a person is identity, never status. A status is a symbol on a small
    /// disc at the edge, so the two are told apart by position and shape rather than by hue.
    ///
    /// Two people can still share a color. It is a hint, never an identifier.
    static func identity(of name: PersonNameComponents) -> Color {
        IdentityPalette.color(for: name)
    }
}

enum IdentityPalette {
    static func color(for name: PersonNameComponents) -> Color {
        colors[index(for: name)]
    }

    // The status hues are here too. Reserving them left four colors, and six people then shared
    // three of them, which is worse than the risk it avoided.
    private static let colors: [Color] = [
        .indigo, .purple, .pink, .brown, .teal,
        .cyan, .blue, .green, .orange, .red,
    ]

    // djb2, not hashValue: Swift seeds hashing per process, so a person would change color on
    // every launch. Summing the bytes instead was tried and clustered, putting half of six
    // sample names on one color.
    private static func index(for name: PersonNameComponents) -> Int {
        let text = name.formatted(.name(style: .long))
        let hash = text.utf8.reduce(UInt64(5381)) { total, byte in total &* 33 &+ UInt64(byte) }
        return Int(hash % UInt64(colors.count))
    }
}
