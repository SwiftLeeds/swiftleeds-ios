import SwiftUI
import UIDesign

/// A view that stands in for the `Badge` component's neutral appearance.
///
/// A quantity or a kind carries no status, so it takes an outline and grey
/// text. Color here would claim a meaning the value does not have.
struct MockNeutralBadge: View {
    /// The word the badge shows.
    let text: String

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.textSecondary)
            .padding(.horizontal, .small)
            .padding(.vertical, .xxSmall)
            .overlay {
                Capsule()
                    .strokeBorder(.borderPrimary, lineWidth: CGFloat(BorderWidth.thin))
            }
    }
}
