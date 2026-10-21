import SwiftUI
import UIDesign

/// A view that offers the moment's action beside a round favorite button.
///
/// Before the session there is no action, so the star stands alone. The star moves under the
/// action when the two do not fit side by side in the width given, and at an accessibility text
/// size.
struct HeroActions: View {
    /// Where a person is in the session's day.
    private let moment: SessionMoment

    /// Whether this person favorited the session.
    @Binding private var isFavorite: Bool

    /// The width the action and the star share, or `nil` until it is measured.
    private let availableWidth: CGFloat?

    /// The text size this person chose.
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// Whether this person has asked to reduce motion.
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// The height of the capsule and the size of the star, which grow with the text.
    @ScaledMetric(relativeTo: .headline) private var actionHeight: CGFloat = actionHeightAtDefaultSize

    /// The capsule's width on one line, padding included, in points, or `nil` until measured.
    @State private var capsuleWidth: CGFloat?

    /// Creates the actions for one session.
    ///
    /// - Parameters:
    ///   - moment: Where a person is in the session's day.
    ///   - isFavorite: Whether this person favorited the session. The star changes it.
    ///   - availableWidth: The width the action and the star share, in points, or `nil` until it
    ///     is measured. The star then stands under the action.
    init(moment: SessionMoment, isFavorite: Binding<Bool>, availableWidth: CGFloat?) {
        self.moment = moment
        _isFavorite = isFavorite
        self.availableWidth = availableWidth
    }

    /// The capsule and the star, side by side or one under the other.
    var body: some View {
        layout {
            momentAction

            favoriteButton
        }
    }
}

// MARK: - Constants

extension HeroActions {
    /// The height of the capsule and the size of the star at the default text size, in points.
    private static let actionHeightAtDefaultSize: CGFloat = 48

    /// The least a tap target measures on either side, in points.
    private static let tapTarget: CGFloat = 44

    /// How opaque the star's disc is, against white.
    private static let discOpacity: Double = 0.25

    /// The space between the capsule and the star, in points.
    private static let actionSpacing = CGFloat(Spacing.medium)
}

// MARK: - Layout

extension HeroActions {
    /// The arrangement of the capsule and the star: side by side, or the star under the capsule.
    private var layout: AnyLayout {
        if dynamicTypeSize.isAccessibilitySize || !fitsBeside {
            AnyLayout(VStackLayout(alignment: .leading, spacing: Self.actionSpacing))
        } else {
            AnyLayout(HStackLayout(alignment: .center, spacing: Self.actionSpacing))
        }
    }

    /// Whether the capsule and the star fit side by side in the width given.
    ///
    /// It is `true` before the session, when there is no capsule. Otherwise it is `false` until the
    /// width and the capsule are measured.
    private var fitsBeside: Bool {
        guard moment != .before else { return true }
        guard let availableWidth, let capsuleWidth else { return false }
        return capsuleWidth + Self.actionSpacing + actionHeight <= availableWidth
    }
}

// MARK: - Capsule

extension HeroActions {
    /// The capsule that suits the moment, or nothing before the session.
    @ViewBuilder
    private var momentAction: some View {
        switch moment {
        case .before: EmptyView()
        case .during: capsuleButton("Ask a Question", symbol: "bubble.left")
        case .after: capsuleButton("Watch", symbol: "play.fill")
        }
    }

    /// A white capsule button with a symbol and a title, which does nothing yet.
    ///
    /// - Parameters:
    ///   - title: The words on the capsule.
    ///   - symbol: The name of the SF Symbol before the title.
    /// - Returns: A button that shows the capsule.
    private func capsuleButton(_ title: LocalizedStringKey, symbol: String) -> some View {
        // The symbol is a bare name because `Icon` names neither a speech bubble nor a play
        // symbol, and `UIDesign` is not edited on this branch.
        Button {
        } label: {
            capsuleLabel(title, symbol: symbol)
                .frame(minHeight: actionHeight)
                .background(.white, in: .capsule)
                .contentShape(.capsule)
                .background {
                    capsuleLabel(title, symbol: symbol)
                        .fixedSize()
                        .hidden()
                        .accessibilityHidden(true)
                        .onGeometryChange(for: CGFloat.self) { proxy in
                            proxy.size.width
                        } action: { width in
                            capsuleWidth = width
                        }
                }
        }
        .buttonStyle(.plain)
    }

    /// Returns the words and symbol of a capsule, with its padding.
    ///
    /// - Parameters:
    ///   - title: The words on the capsule.
    ///   - symbol: The name of the SF Symbol before the title.
    /// - Returns: A label that wraps to the width it is given.
    private func capsuleLabel(_ title: LocalizedStringKey, symbol: String) -> some View {
        Label(title, systemImage: symbol)
            .font(.headline)
            .foregroundStyle(.black)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, .large)
            .padding(.vertical, .small)
    }
}

// MARK: - Star

extension HeroActions {
    /// How far the star's tap target reaches past its disc, so the target meets the minimum size.
    private var starHitInset: CGFloat {
        max(0, (Self.tapTarget - actionHeight) / 2)
    }

    /// The star's label, which names what the star does now.
    private var favoriteLabel: LocalizedStringKey {
        isFavorite ? "Remove from Favourites" : "Add to Favourites"
    }

    /// The round star that favorites the session or takes the mark away.
    private var favoriteButton: some View {
        Button {
            toggleFavorite()
        } label: {
            Image(icon: isFavorite ? .favoriteFilled : .favorite)
                .contentTransition(reduceMotion ? .identity : .symbolEffect(.replace))
                .font(.title3)
                .foregroundStyle(SessionHero.onHero)
                .frame(width: actionHeight, height: actionHeight)
                .background(SessionHero.onHero.opacity(Self.discOpacity), in: .circle)
                .contentShape(Rectangle().inset(by: -starHitInset))
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.success, trigger: isFavorite)
        .accessibilityLabel(favoriteLabel)
        .accessibilityAddTraits(isFavorite ? .isSelected : [])
    }

    /// Marks the session as a favorite, or takes the mark away.
    private func toggleFavorite() {
        if reduceMotion {
            isFavorite.toggle()
        } else {
            withAnimation { isFavorite.toggle() }
        }
    }
}
