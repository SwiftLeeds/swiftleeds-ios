import SwiftUI

/// The colors that report an outcome or a state.
extension ShapeStyle where Self == Color {
    /// It worked, or it is confirmed.
    ///
    /// Use it for text or a symbol on a surface, not as a fill behind text. It reaches 4.5:1
    /// against every surface, grouped or not, in light, dark and Increase Contrast.
    public static var success: Color { ColorFamily.success.text }

    /// It needs attention, though nothing has failed.
    ///
    /// Use it for text or a symbol on a surface, not as a fill behind text. It reaches 4.5:1
    /// against every surface, grouped or not, in light, dark and Increase Contrast.
    public static var warning: Color { ColorFamily.warning.text }

    /// It failed, or it destroys something.
    ///
    /// Use it for text or a symbol on a surface, not as a fill behind text. It reaches 4.5:1
    /// against every surface, grouped or not, in light, dark and Increase Contrast.
    public static var error: Color { ColorFamily.error.text }

    /// Neutral information, or work in progress.
    ///
    /// Use it for text or a symbol on a surface, not as a fill behind text. It reaches 4.5:1
    /// against every surface, grouped or not, in light, dark and Increase Contrast.
    public static var info: Color { ColorFamily.info.text }
}
