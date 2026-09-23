import SwiftUI

/// The colours that report an outcome or a state.
///
/// Each one names a role, never a feature. Map a screen's own word onto one of these.
///
/// Don't carry meaning in colour alone. Pair it with a word or a symbol.
public extension ShapeStyle where Self == Color {
    /// It worked, or it is confirmed.
    static var success: Color { .green }

    /// It needs attention, though nothing has failed.
    static var warning: Color { .orange }

    /// It failed, or it destroys something.
    static var error: Color { .red }

    /// Neutral information, or work in progress.
    static var info: Color { .blue }
}
