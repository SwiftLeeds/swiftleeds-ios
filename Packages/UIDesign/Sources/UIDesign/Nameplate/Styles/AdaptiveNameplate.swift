import SwiftUI

/// The body the built-in nameplate styles share.
///
/// It puts the icon beside the text, and above it at the accessibility text
/// sizes.
struct AdaptiveNameplate: View {
    /// The text size the reader chose in system settings.
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// The views to draw.
    let configuration: NameplateStyleConfiguration

    /// The font the title draws in. The detail keeps body size at every style.
    let titleFont: Font

    var body: some View {
        layout {
            configuration.icon

            VStack(alignment: .leading, spacing: .xxSmall) {
                configuration.title
                    .font(titleFont)
                    .foregroundStyle(.textPrimary)

                configuration.detail
                    .font(.body)
                    .foregroundStyle(.textSecondary)
            }
            // The nameplate reads as one element, and VoiceOver combines its
            // children in order. This reads the name before any status mark
            // the avatar carries.
            .accessibilitySortPriority(1)
        }
        // Fill the width the caller gives, so a row stays leading aligned. A
        // trailing Spacer would instead make the stacked form greedy for
        // height.
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// A row, or a stack once the text is too large to sit beside the icon.
    private var layout: AnyLayout {
        if dynamicTypeSize.isAccessibilitySize {
            AnyLayout(VStackLayout(alignment: .leading, spacing: CGFloat(Spacing.medium)))
        } else {
            AnyLayout(HStackLayout(alignment: .center, spacing: CGFloat(Spacing.medium)))
        }
    }
}
