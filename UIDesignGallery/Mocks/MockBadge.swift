import SwiftUI
import UIDesign

/// A view that stands in for the `Badge` component, which is not built yet.
///
/// A status takes its own tint as the text color and the same tint, faded, as
/// the fill.
struct MockBadge: View {
    /// The word the badge shows.
    let text: String

    /// The color that says which status this is.
    let tint: Color

    /// How faint the fill is against the text.
    private static let fillOpacity: Double = 0.15

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, .small)
            .padding(.vertical, .xxSmall)
            .background(tint.opacity(Self.fillOpacity), in: .capsule)
    }
}
