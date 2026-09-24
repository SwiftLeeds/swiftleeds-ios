import SwiftUI
import UIDesign

/// A view that washes a screen in a soft tint rather than filling it flat.
///
/// The reference app samples the tint from the screen's own artwork. A screen
/// with no artwork falls back to the conference's color.
struct AmbientBackground: View {
    /// The color the wash takes.
    var color: Color = .brandPrimary

    /// How strong the wash is where it starts.
    ///
    /// The reference app's wash reads as a lift on the background rather than
    /// as a color, so this stays low enough that the screen still reads dark.
    private static let tintOpacity: Double = 0.10

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
            .overlay {
                LinearGradient(
                    colors: [Self.tint(color), .clear],
                    startPoint: .top,
                    endPoint: .center
                )
            }
            .ignoresSafeArea()
    }
}
