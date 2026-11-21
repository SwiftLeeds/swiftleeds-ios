import SwiftUI

/// The default notice style.
///
/// You can also use ``NoticeStyle/automatic`` to construct this style.
///
/// The title, the description and the actions are essential: VoiceOver reads them, and they scale
/// with the text size. The icon only decorates, so VoiceOver skips it and the style hides it at
/// accessibility text sizes, which leaves the text the full width.
///
/// The system's borderless button takes taps a little above and below its label. The style leaves
/// a space of ``Spacing/lg`` above the actions, so a tap on the text never runs them. The style
/// never sets a button style itself.
public struct DefaultNoticeStyle: NoticeStyle {
    /// A view that draws the parts of a notice, with the icon beside the text.
    private struct Content: View {
        /// The properties of the notice.
        let configuration: NoticeStyleConfiguration

        /// The current Dynamic Type size.
        @Environment(\.dynamicTypeSize) private var dynamicTypeSize

        var body: some View {
            HStack(alignment: .firstTextBaseline, spacing: .md) {
                if !dynamicTypeSize.isAccessibilitySize {
                    configuration.icon
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .dynamicTypeSize(.large)
                }
                VStack(alignment: .leading, spacing: .lg) {
                    VStack(alignment: .leading, spacing: .xs) {
                        configuration.title
                            .font(.headline)
                            .fixedSize(horizontal: false, vertical: true)
                        configuration.description
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .accessibilityElement(children: .combine)
                    configuration.actions
                        .multilineTextAlignment(.leading)
                }
            }
        }
    }

    /// Creates a default notice style.
    public init() {}

    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        Content(configuration: configuration)
    }
}

extension NoticeStyle where Self == DefaultNoticeStyle {
    /// The default notice style.
    public static var automatic: DefaultNoticeStyle { DefaultNoticeStyle() }
}
