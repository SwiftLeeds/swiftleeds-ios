import SwiftUI

/// The body the built-in nameplate styles share.
///
/// It puts the icon beside the text, and above it at the accessibility text sizes.
struct AdaptiveNameplate: View {
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
        }
        // The nameplate fills the width it is given, so a row stays leading aligned. A trailing
        // Spacer cannot do this: it would push the icon and the text apart when they stack.
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // A row leaves the text about a third of the width at these sizes, so the text goes below the
    // icon instead. Apple asks for the same in Typography, under Dynamic Type.
    private var layout: AnyLayout {
        if dynamicTypeSize.isAccessibilitySize {
            AnyLayout(VStackLayout(alignment: .leading, spacing: CGFloat(Spacing.medium)))
        } else {
            AnyLayout(HStackLayout(alignment: .center, spacing: CGFloat(Spacing.medium)))
        }
    }
}
