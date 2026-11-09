import SwiftUI

/// A nameplate layout that centers the icon above the title and the detail.
///
/// The title and the detail each keep to one line, and a line too long for the
/// width ends with an ellipsis.
struct StackedNameplate: View {
    /// The properties of the nameplate.
    let configuration: NameplateStyleConfiguration

    /// The font the title draws in.
    let titleFont: Font

    var body: some View {
        VStack(alignment: .center, spacing: .md) {
            configuration.icon

            text
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    /// The title above the detail.
    private var text: some View {
        VStack(alignment: .center, spacing: .xxs) {
            configuration.title
                .font(titleFont)
                .foregroundStyle(.text)
                .lineLimit(1)

            configuration.detail
                .font(.body)
                .foregroundStyle(.secondaryText)
                .lineLimit(1)
        }
        // VoiceOver combines the children in order. This reads the name before
        // the status of the icon's avatar.
        .accessibilitySortPriority(1)
    }
}
