import SharedAssets
import SwiftUI

/// The conference's own colours.
///
/// These read a legacy catalog, so the values are provisional. The names are not.
public extension ShapeStyle where Self == Color {
    /// The colour that marks something as ours.
    ///
    /// It has no dark variant yet, so it looks the same in both appearances.
    static var brandPrimary: Color { Color.accent }
}

// No brandSecondary: the repo holds one brand colour. Adding one is a colour decision.
