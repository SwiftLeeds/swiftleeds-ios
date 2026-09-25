import SwiftUI
import UIDesign

/// A view that states a condition and offers the action that settles it.
///
/// It sits in the content and scrolls with it. Nothing about it floats over
/// the screen, and nothing about it times out, so it is not a toast.
struct MockNotice: View {
    /// How large this person has asked text to be.
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// The SF Symbol that stands for what the notice is about.
    let symbol: String

    /// The condition, in one sentence.
    let message: String

    /// What the action offers to do about the condition.
    let actionTitle: String

    /// How wide and tall the close button is.
    ///
    /// The glyph inside it is much smaller, so the button reaches past the
    /// card's own padding to meet the smallest target iOS asks for.
    private static let closeSide = CGFloat(IconSize.xxLarge)

    var body: some View {
        VStack(spacing: 0) {
            statement

            Divider()

            action
        }
        .contentGroup()
    }

    /// How the statement arranges its symbol and its sentence.
    ///
    /// At an accessibility size the two stack, which gives the sentence the
    /// whole width instead of the share a grown symbol leaves it.
    private var statementLayout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: CGFloat(Spacing.small)))
            : AnyLayout(HStackLayout(alignment: .top, spacing: CGFloat(Spacing.medium)))
    }

    /// The symbol and the sentence, with the close button over them.
    private var statement: some View {
        statementLayout {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(.textSecondary)
                .accessibilityHidden(true)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.large)
        // The sentence stops short of the close button, which is an overlay so
        // that its 44 points do not set this row's height.
        .padding(.trailing, .medium)
        .overlay(alignment: .topTrailing) { close }
    }

    /// The button that puts the notice away.
    private var close: some View {
        Button {} label: {
            Image(systemName: "xmark")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.textTertiary)
                .frame(width: Self.closeSide, height: Self.closeSide)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Dismiss")
    }

    /// The one action the notice offers, across the foot of the card.
    ///
    /// It takes the tint as its text and no fill at all. A filled action here
    /// would outrank the screen's own.
    private var action: some View {
        Button {} label: {
            Text(actionTitle)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.brandPrimary)
                .frame(maxWidth: .infinity, minHeight: Self.closeSide)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}
