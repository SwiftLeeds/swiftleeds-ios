import SwiftUI
import UIDesign

/// A view that stands in for the `Badge` component's role appearance.
///
/// A role takes the colors its halo runs between, so the word and the ring
/// read as one thing. It never takes a flat status color: a filled capsule is
/// the shape a status already uses, and green, amber and purple are spoken
/// for.
struct MockRoleBadge: View {
    /// The standing this badge names.
    let role: ConferenceRole

    /// How faint the fill is against the text.
    private static let fillOpacity: Double = 0.18

    /// The colors the fill and the border run between.
    private var colors: LinearGradient {
        LinearGradient(colors: role.colors, startPoint: .leading, endPoint: .trailing)
    }

    var body: some View {
        Text(role.name)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.textPrimary)
            .padding(.horizontal, .small)
            .padding(.vertical, .xxSmall)
            .background(colors.opacity(Self.fillOpacity), in: .capsule)
            .overlay {
                Capsule().strokeBorder(colors, lineWidth: CGFloat(BorderWidth.thin))
            }
    }
}
