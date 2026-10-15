import SwiftUI
import UIDesign

/// A toolbar button whose label and symbol follow whether a subject is saved.
struct FavoriteButton: View {
    /// Whether the subject is saved.
    @Binding var isFavorite: Bool

    /// Whether this person has asked to reduce motion.
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button {
            toggle()
        } label: {
            Label {
                Text(isFavorite ? "Unsave" : "Save")
            } icon: {
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .contentTransition(reduceMotion ? .identity : .symbolEffect(.replace))
            }
        }
        .tint(.textPrimary)
        .sensoryFeedback(.success, trigger: isFavorite)
    }

    /// Saves the subject, or takes it off the saved list.
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
