import SwiftUI
import UIDesign

/// A view that stands in for the `Artwork` component, which is not built yet.
///
/// A session has no picture yet, so this draws a stable one from the session's
/// own name. The point is to give the glass and the ambient wash something to
/// sit over, which a flat fill cannot do.
struct MockArtwork: View {
    /// The text the picture is derived from.
    let seed: String

    /// The corner radius the picture takes.
    var cornerRadius: CornerRadius = .large

    /// The colors this seed maps onto, in a fixed order.
    private static let palette: [Color] = [
        .init(red: 0.85, green: 0.28, blue: 0.24),
        .init(red: 0.93, green: 0.58, blue: 0.16),
        .init(red: 0.22, green: 0.46, blue: 0.80),
        .init(red: 0.35, green: 0.66, blue: 0.44),
        .init(red: 0.52, green: 0.32, blue: 0.72),
    ]

    /// The two colors this seed's picture runs between.
    private var colors: [Color] {
        let index = Self.index(of: seed)
        let next = (index + 1) % Self.palette.count
        return [Self.palette[index], Self.palette[next]]
    }

    /// Returns which color a seed maps onto.
    ///
    /// `hashValue` is seeded once per launch, so it would give the same session
    /// a different picture every time the app starts.
    ///
    /// - Parameter seed: The text the picture is derived from.
    private static func index(of seed: String) -> Int {
        let total = seed.utf8.reduce(0) { $0 + Int($1) }
        return total % palette.count
    }

    var body: some View {
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            .overlay {
                Image(systemName: "mic.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(.white.opacity(0.35))
            }
            .clipShape(
                RoundedRectangle(cornerRadius: CGFloat(cornerRadius), style: .continuous)
            )
            .accessibilityHidden(true)
    }
}

extension MockArtwork {
    /// The color the ambient wash takes from this seed's picture.
    ///
    /// - Parameter seed: The text the picture is derived from.
    static func tint(for seed: String) -> Color {
        palette[index(of: seed)]
    }
}
