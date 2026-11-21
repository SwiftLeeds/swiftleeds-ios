import SwiftUI

/// The default notice style.
///
/// You can also use ``NoticeStyle/automatic`` to construct this style.
///
/// The style draws the icon beside the text. At accessibility text sizes it hides the icon, which
/// only decorates, so the text keeps the width.
///
/// The accessibility frame of a single line of actions grows to the minimum target size Apple
/// sets. It reaches up no further than the space above the actions. The style never sets a
/// button style itself.
public struct DefaultNoticeStyle: NoticeStyle {
    /// A view that draws the parts of a notice, with the icon beside the text.
    private struct Content: View {
        /// The accessibility frame around the actions.
        private struct HitBand: Shape {
            /// How far the area reaches above the actions, in points.
            let above: CGFloat

            /// How far the area reaches below the actions, in points.
            let below: CGFloat

            /// How far the area reaches to the left and the right of the actions, in points.
            let sides: CGFloat

            func path(in rect: CGRect) -> Path {
                Path(
                    CGRect(
                        x: rect.minX - sides,
                        y: rect.minY - above,
                        width: rect.width + sides * Content.bothSides,
                        height: rect.height + above + below,
                    )
                )
            }
        }

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

        /// How far the actions' accessibility frame grows in total, in points.
        ///
        /// It makes a single line of actions reach the minimum target side. Taller actions do not grow.
        private var growth: CGFloat {
            max(0, Self.minimumTargetSide - actionsHeight)
        }

        /// The accessibility frame around the actions.
        ///
        /// It reaches up no further than the space above the actions. The rest goes below.
        private var hitBand: HitBand {
            let above = min(growth / Self.bothSides, CGFloat(Spacing.sm))
            return HitBand(above: above, below: growth - above, sides: growth / Self.bothSides)
        }

        var body: some View {
            HStack(alignment: .firstTextBaseline, spacing: .md) {
                if !dynamicTypeSize.isAccessibilitySize {
                    configuration.icon
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .dynamicTypeSize(.large)
                }
                VStack(alignment: .leading, spacing: .sm) {
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
                        .onGeometryChange(for: CGFloat.self) { geometry in
                            geometry.size.height
                        } action: { height in
                            actionsHeight = height
                        }
                        .contentShape(hitBand)
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
