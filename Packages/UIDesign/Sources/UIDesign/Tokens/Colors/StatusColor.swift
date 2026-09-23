import SwiftUI

/// The colours that report an outcome or a state.
///
/// These name a role, never a feature. A screen maps its own word onto one of these, so a
/// "sold out" tag reaches for `error` rather than adding a token.
///
/// Never carry the meaning in colour alone. Pair it with a word or a symbol, because about one
/// man in twelve cannot tell red from green.
public extension ShapeStyle where Self == Color {
    /// It worked, or it is confirmed.
    static var success: Color { .green }

    /// It needs attention, but nothing is broken.
    static var warning: Color { .orange }

    /// It failed, or it is destructive.
    static var error: Color { .red }

    /// Neutral information, or something in progress.
    static var info: Color { .blue }
}
