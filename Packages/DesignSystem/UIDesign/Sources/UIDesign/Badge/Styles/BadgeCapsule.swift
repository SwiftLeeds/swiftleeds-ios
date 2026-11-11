import SwiftUI

/// A view that draws a badge's label on a filled capsule, with padding that grows with the text.
struct BadgeCapsule: View {
    /// How far the text size has grown from its default.
    @ScaledMetric(relativeTo: .caption) private var textScale: CGFloat = 1

    /// The properties of the badge.
    let configuration: BadgeStyleConfiguration

    /// The color of the capsule.
    let fill: Color

    /// The color of the label's word and icon.
    let foreground: Color

    var body: some View {
        configuration.label
            .labelStyle(.titleAndIcon)
            .labelIconToTitleSpacing(.xs)
            .imageScale(.small)
            .font(.caption.weight(.semibold))
            .foregroundStyle(foreground)
            .padding(.horizontal, .sm, scaledBy: textScale)
            .padding(.vertical, .xxs, scaledBy: textScale)
            .background(fill, in: Capsule())
    }
}
