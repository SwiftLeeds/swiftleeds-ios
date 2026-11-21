import SwiftUI

/// The default notice style.
///
/// You can also use ``NoticeStyle/automatic`` to construct this style.
public struct DefaultNoticeStyle: NoticeStyle {
    /// A view that draws the parts of a notice, with the icon beside or above the text.
    private struct Content: View {
        /// The smallest side of a tappable target, in points, as Apple sets it.
        private static let minimumTargetSide: CGFloat = 44

        /// The number of sides a target grows on, such as top and bottom.
        private static let bothSides: CGFloat = 2

        /// The properties of the notice.
        let configuration: NoticeStyleConfiguration

        /// The current Dynamic Type size.
        @Environment(\.dynamicTypeSize) private var dynamicTypeSize

        /// The measured height of the actions, in points.
        @State private var actionsHeight: CGFloat = 0

        /// The icon beside the text, or above it at accessibility sizes, where the text needs the width.
        private var layout: AnyLayout {
            if dynamicTypeSize.isAccessibilitySize {
                AnyLayout(VStackLayout(alignment: .leading, spacing: .md))
            } else {
                AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: .md))
            }
        }

        /// How far the actions' tappable area grows on every side, in points.
        ///
        /// It makes a single line of actions reach the minimum target side. Taller actions do not grow.
        private var hitInset: CGFloat {
            max(0, (Self.minimumTargetSide - actionsHeight) / Self.bothSides)
        }

        var body: some View {
            layout {
                configuration.icon
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .dynamicTypeSize(.large)
                VStack(alignment: .leading, spacing: .sm) {
                    VStack(alignment: .leading, spacing: .xs) {
                        configuration.title
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                        configuration.description
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .accessibilityElement(children: .combine)
                    configuration.actions
                        .onGeometryChange(for: CGFloat.self) { geometry in
                            geometry.size.height
                        } action: { height in
                            actionsHeight = height
                        }
                        .contentShape(Rectangle().inset(by: -hitInset))
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
