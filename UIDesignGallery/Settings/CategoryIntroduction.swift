import SwiftUI
import UIDesign

/// A view that opens a Settings category's screen with its icon, its name and
/// one sentence on what the screen is for.
///
/// It is the first row of the screen's first section, so that section's
/// rounded group is the card around it. The icon sits above the name, as
/// Apple's own settings screens lay it out, which is why this is not a
/// `Nameplate`.
///
/// VoiceOver reads it as one element: the name, then the sentence.
struct CategoryIntroduction: View {
    /// The category the screen is about.
    let category: SettingsCategory

    var body: some View {
        VStack(alignment: .leading, spacing: .medium) {
            CategoryIcon(category: category, placement: .introduction)

            VStack(alignment: .leading, spacing: .xSmall) {
                Text(category.title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.textPrimary)

                Text(category.detail)
                    .font(.body)
                    .foregroundStyle(.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, .small)
        .accessibilityElement(children: .combine)
    }
}
