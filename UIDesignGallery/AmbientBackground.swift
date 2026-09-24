import SwiftUI
import UIDesign

/// A view that washes a screen in a soft tint rather than filling it flat.
///
/// The reference app samples the tint from the screen's own artwork. Nothing
/// here has artwork yet, so the wash comes from the conference's color.
struct AmbientBackground: View {
    /// How strong the wash is where it starts.
    ///
    /// The reference app's wash reads as a lift on the background rather than
    /// as a color, so this stays low enough that the screen still reads dark.
    private static let tintOpacity: Double = 0.10

    var body: some View {
        Color.surface
            .overlay {
                LinearGradient(
                    colors: [.brandPrimary.opacity(Self.tintOpacity), .clear],
                    startPoint: .top,
                    endPoint: .center
                )
            }
            .ignoresSafeArea()
    }
}
