import SwiftUI
import UIDesign

/// A person's initials in light, grey type on a plain disc.
struct QuietInitials: View {
    /// The name the initials abbreviate.
    private let name: PersonNameComponents

    /// How far the text size has grown from its default, as far as the avatar
    /// follows it.
    @ScaledMetric(relativeTo: .body) private var textScale: CGFloat = 1

    /// The size of the initials at the default text size.
    private static let baseSize: CGFloat = 30

    /// How opaque the initials are against the primary text color, which
    /// makes them grey.
    private static let opacity: Double = 0.6

    /// The most the avatar grows with the text size, which its initials match.
    private static let largestGrowth: CGFloat = 1.75

    /// Creates the initials of a name.
    ///
    /// - Parameter name: The name the initials abbreviate.
    init(_ name: PersonNameComponents) {
        self.name = name
    }

    /// The initials, centered on the disc.
    var body: some View {
        Color.secondarySurface
            .overlay {
                Text(name.formatted(.name(style: .abbreviated)))
                    .font(.system(size: Self.baseSize * min(textScale, Self.largestGrowth)))
                    .fontWeight(.regular)
                    .foregroundStyle(Color.textPrimary.opacity(Self.opacity))
            }
    }
}
