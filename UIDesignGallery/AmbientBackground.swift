import SwiftUI
import UIDesign

/// A view that washes a screen in a soft tint rather than filling it flat.
///
/// The reference app samples the tint from the screen's own artwork. A screen
/// with no artwork falls back to the conference's color.
struct AmbientBackground: View {
    /// The color the wash takes.
    ///
    /// The default is neutral on purpose. A screen with no artwork has nothing
    /// to sample, and washing it in the conference's color instead reads as a
    /// colored screen rather than as depth.
    var color: Color = .textPrimary

    /// How strong the wash is where it starts.
    private static let tintOpacity: Double = 0.18

    /// How far the wash is off the background by the time it reaches the foot.
    ///
    /// The reference app washes the whole screen. A wash that fades out by the
    /// middle leaves the lower half flat, which is what read as too black.
    private static let footOpacity: Double = 0.35

    /// How far the background sits off pure black.
    ///
    /// The reference app's dark screens are a smoky grey, not black, and that
    /// is what gives a material above them something to lighten.
    private static let lift: Double = 0.06

    /// Returns the wash a surface takes so it shares the screen's temperature.
    ///
    /// A surface that takes a flat fill looks lit by a different light. Drawing
    /// this over it puts both under the same one.
    ///
    /// - Parameter color: The color the screen's wash takes.
    static func tint(_ color: Color) -> Color {
        color.opacity(tintOpacity)
    }

    var body: some View {
        Color.surface
            .overlay { Color.textPrimary.opacity(Self.lift) }
            .overlay {
                LinearGradient(
                    colors: [
                        Self.tint(color),
                        Self.tint(color).opacity(Self.footOpacity),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .ignoresSafeArea()
    }
}
