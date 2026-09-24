import SwiftUI

/// A view that lays out a nameplate's icon beside its title and detail, and
/// above them at the accessibility text sizes.
///
/// The built-in nameplate styles share it, so they differ only in typography
/// and spacing.
struct AdaptiveNameplate: View {
    /// The current Dynamic Type size.
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// The properties of the nameplate.
    let configuration: NameplateStyleConfiguration

    /// The font the title draws in. The detail keeps the body text style at
    /// every style.
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
