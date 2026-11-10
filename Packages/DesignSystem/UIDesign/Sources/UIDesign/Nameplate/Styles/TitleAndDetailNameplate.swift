import SwiftUI

/// A nameplate layout that draws the title and the detail without the icon.
///
/// The title and the detail each keep to one line, and a line too long for the
/// width ends with an ellipsis. An avatar's status shows at the trailing end of
/// the title's line.
struct TitleAndDetailNameplate: View {
    /// The properties of the nameplate.
    let configuration: NameplateStyleConfiguration

    /// The font the title draws in.
    let titleFont: Font

    var body: some View {
        VStack(alignment: .leading, spacing: .xxs) {
            titleLine

            configuration.detail
                .font(.body)
                .foregroundStyle(.secondaryText)
                .lineLimit(1)
        }
    }

    /// The title, with the status of the icon's avatar at the trailing edge.
    private var titleLine: some View {
        HStack(alignment: .firstTextBaseline, spacing: .xs) {
            configuration.title
                .lineLimit(1)
                // Take the free width, so the status sits at the trailing edge
                // and every title in a list starts on the same line.
                .frame(maxWidth: .infinity, alignment: .leading)

            // Reads the icon for its status and draws nothing of it.
            Group(subviews: configuration.icon) { subviews in
                if let status = subviews.lazy.compactMap(\.containerValues.avatarStatus).first {
                    statusMark(status)
                }
            }
        }
        .font(titleFont)
        .foregroundStyle(.text)
    }

    /// Draws the symbol of a status, with its label for VoiceOver.
    ///
    /// - Parameter status: The status to draw.
    /// - Returns: A view that shows only the symbol of the status.
    private func statusMark(_ status: AvatarStatus) -> some View {
        Label {
            Text(status.label)
        } icon: {
            Image(icon: status.icon)
                .symbolRenderingMode(.palette)
                .foregroundStyle(status.family.onSolid, status.family.solid)
        }
        .labelStyle(.iconOnly)
        .accessibilityStatusTraits()
    }
}
