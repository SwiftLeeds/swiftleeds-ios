import SwiftUI

/// The backgrounds a screen is built from, in three levels of depth.
///
/// Each one names the system colour for this platform, so nothing else has to write `#if os`.
public extension ShapeStyle where Self == Color {
    /// The background of a screen.
    static var surface: Color {
        #if os(iOS)
        Color(.systemBackground)
        #else
        Color(.windowBackgroundColor)
        #endif
    }

    /// The background of grouped content on a screen, such as a card.
    static var secondarySurface: Color {
        #if os(iOS)
        Color(.secondarySystemBackground)
        #else
        Color(.controlBackgroundColor)
        #endif
    }

    /// The background of an element inside grouped content.
    static var tertiarySurface: Color {
        #if os(iOS)
        Color(.tertiarySystemBackground)
        #else
        Color(.underPageBackgroundColor)
        #endif
    }
}
