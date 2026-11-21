import SwiftUI

/// A view that draws a short text on the avatar fill, sized to the avatar.
///
/// The text takes its size from the avatar's diameter rather than from the text size, which the
/// avatar has already answered.
struct AvatarFillText: View {
    /// The diameter of the avatar containing this view.
    @Environment(\.avatarDiameter) private var diameter

    /// The text to draw.
    private let text: Text

    /// Whether the text may shrink to fit the avatar.
    private let shrinksToFit: Bool

    /// The font size, as a fraction of the avatar's diameter.
    private static let proportion: CGFloat = 0.40

    /// The smallest fraction of its size that text may shrink to.
    private static let smallestScale: CGFloat = 0.5

    /// Creates a view that draws a text on the avatar fill.
    ///
    /// - Parameters:
    ///   - text: The text to draw.
    ///   - shrinksToFit: Whether the text may shrink to fit the avatar. A bare `Bool` because it is
    ///     a view-layer switch with two states, named at each call site.
    init(_ text: Text, shrinksToFit: Bool) {
        self.text = text
        self.shrinksToFit = shrinksToFit
    }

    var body: some View {
        Rectangle().fill(.avatarFill)
            .overlay {
                text
                    .font(.system(size: CGFloat(diameter) * Self.proportion, weight: .medium))
                    .foregroundStyle(.avatarInitials)
                    .lineLimit(1)
                    .minimumScaleFactor(shrinksToFit ? Self.smallestScale : 1)
            }
    }
}
