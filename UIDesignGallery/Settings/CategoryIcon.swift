import SwiftUI
import UIDesign

/// A view that marks a Settings category with its symbol on a colored square.
///
/// The same icon sits on the category's row in the Settings root and, larger,
/// at the top of the screen that row opens, so the two read as one thing.
///
/// The icon is decoration: the title beside it names the category, so
/// VoiceOver skips it. It still scales with the text size, because the symbol
/// inside it is text and scales anyway, and the square grows to keep it.
struct CategoryIcon: View {
    /// Where the icon sits, which sets its size.
    enum Placement {
        /// On a row in the Settings root.
        case row

        /// At the top of the category's own screen.
        case introduction
    }

    /// The side of a row icon, measured from Apple's Settings root.
    private static let rowSide: CGFloat = 29

    /// The side of an introduction icon, measured from Apple's General screen.
    private static let introductionSide: CGFloat = 60

    /// The category the icon stands for.
    let category: SettingsCategory

    /// Where the icon sits.
    let placement: Placement

    /// How much larger this text size makes the icon.
    @ScaledMetric(relativeTo: .body) private var scale: CGFloat = 1

    var body: some View {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
            .fill(tint)
            .overlay {
                Image(systemName: category.symbol)
                    .font(glyph)
                    .foregroundStyle(.white)
            }
            .frame(width: side, height: side)
            .accessibilityHidden(true)
    }

    /// How wide and tall the icon is at this text size.
    private var side: CGFloat {
        switch placement {
        case .row: Self.rowSide * scale
        case .introduction: Self.introductionSide * scale
        }
    }

    /// How rounded the square's corners are at this text size.
    private var radius: CGFloat {
        switch placement {
        case .row: CGFloat(CornerRadius.small) * scale
        case .introduction: CGFloat(CornerRadius.medium) * scale
        }
    }

    /// The text style the symbol takes, which sets its size.
    private var glyph: Font {
        switch placement {
        case .row: .body.weight(.semibold)
        case .introduction: .largeTitle.weight(.medium)
        }
    }

    /// The color behind the symbol.
    ///
    /// Each category has its own, so the four rows tell apart at a glance. The
    /// hues sit outside the status set and away from the brand's: a category's
    /// color is its identity, not a state and not a selection.
    private var tint: Color {
        switch category {
        case .appearance: .indigo
        case .notifications: .purple
        case .about: .gray
        case .contact: .teal
        }
    }
}
