import SharedAssets
import SwiftUI

/// The conference's own colours.
///
/// These read a legacy asset catalog, so the values are provisional. The names are the contract
/// and will not change when the catalog moves into this package.
public extension ShapeStyle where Self == Color {
    /// The colour that marks something as ours, used for a tint or a prominent fill.
    ///
    /// It has no dark variant yet, so it looks the same in both appearances.
    static var brandPrimary: Color { Color.accent }
}

// There is no brandSecondary. This repo holds one brand colour. The only other candidate is the
// buy-ticket gradient's end stop, and that is grey, so it is a fade rather than a second colour.
// Adding one needs a colour choice, not a code change.
