import SwiftUI

/// The colors that report an outcome or a state.
extension ShapeStyle where Self == Color {
    /// It worked, or it is confirmed.
    public static var success: Color { .green }

    /// It needs attention, though nothing has failed.
    public static var warning: Color { .orange }

    /// It failed, or it destroys something.
    public static var error: Color { .red }

    /// Neutral information, or work in progress.
    public static var info: Color { .blue }
}
