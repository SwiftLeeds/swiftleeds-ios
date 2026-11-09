import SwiftUI

/// A nameplate layout that draws the title and the detail without the icon.
///
/// The title and the detail each keep to one line, and a line too long for the
/// width ends with an ellipsis.
struct TitleAndDetailNameplate: View {
    /// The properties of the nameplate.
    let configuration: NameplateStyleConfiguration

    /// The font the title draws in.
    ///
    /// The detail keeps the body text style at every style.
    let titleFont: Font

    var body: some View {
        VStack(alignment: .leading, spacing: .xxs) {
            configuration.title
                .font(titleFont)
                .foregroundStyle(.text)
                .lineLimit(1)

            configuration.detail
                .font(.body)
                .foregroundStyle(.secondaryText)
                .lineLimit(1)
        }
        // The nameplate reads as one element, and VoiceOver combines its
        // children in order. This reads the name before the detail.
        .accessibilitySortPriority(1)
        // Fill the width the caller gives, so a row stays leading aligned.
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
