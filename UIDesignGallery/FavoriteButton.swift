import SwiftUI
import UIDesign

/// A toolbar button that favourites a subject, or takes the mark away.
struct FavoriteButton: View {
    /// Whether the subject is a favourite.
    @Binding var isFavorite: Bool

    /// Whether this person has asked to reduce motion.
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button {
            toggle()
        } label: {
            Label {
                Text(isFavorite ? "Unfavourite" : "Favourite")
            } icon: {
                Image(icon: isFavorite ? .favoriteFilled : .favorite)
                    .contentTransition(reduceMotion ? .identity : .symbolEffect(.replace))
            }
        }
        .tint(.textPrimary)
        .sensoryFeedback(.success, trigger: isFavorite)
    }

    /// Marks the subject as a favourite, or takes the mark away.
    ///
    /// The symbol replaces itself with an animation, unless this person has
    /// asked to reduce motion.
    private func toggle() {
        if reduceMotion {
            isFavorite.toggle()
        } else {
            withAnimation { isFavorite.toggle() }
        }
    }
}
