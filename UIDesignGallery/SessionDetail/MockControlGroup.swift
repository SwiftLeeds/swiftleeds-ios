import SwiftUI
import UIDesign

/// A view that stands in for the session detail screen's related actions.
///
/// The actions sit inside a scroll view, so they take solid token fills rather
/// than glass. Only one of them is tinted, because a region that tints
/// everything says nothing.
struct MockControlGroup: View {
    /// One action's symbol, title, and whether it is the tinted one.
    private struct Action: Identifiable {
        /// Tells one action from another.
        var id: String { title }

        /// The SF Symbol the tile shows.
        let symbol: String

        /// The word under the symbol.
        let title: String

        /// Whether this is the region's one tinted action.
        let isProminent: Bool
    }

    /// The four actions this screen offers, most important first.
    private static let actions: [Action] = [
        Action(symbol: "star", title: "Favourite", isProminent: true),
        Action(symbol: "calendar.badge.plus", title: "Calendar", isProminent: false),
        Action(symbol: "square.and.arrow.up", title: "Share", isProminent: false),
        Action(symbol: "ellipsis", title: "More", isProminent: false),
    ]

    var body: some View {
        HStack(spacing: .small) {
            ForEach(Self.actions) { action in
                tile(action)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    /// Returns one action drawn as a tile.
    ///
    /// - Parameter action: The action to draw.
    private func tile(_ action: Action) -> some View {
        Button {} label: {
            VStack(spacing: .xSmall) {
                Image(systemName: action.symbol)
                    .font(.title3)
                    .frame(height: 24)

                Text(action.title)
                    .font(.caption)
            }
            .foregroundStyle(
                action.isProminent ? AnyShapeStyle(.textOnBrand) : AnyShapeStyle(.textPrimary)
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical, .medium)
            .background {
                RoundedRectangle(cornerRadius: CGFloat(CornerRadius.medium))
                    .fill(
                        action.isProminent
                            ? AnyShapeStyle(.brandPrimary)
                            : AnyShapeStyle(.secondarySurface)
                    )
            }
        }
        .buttonStyle(.plain)
    }
}
