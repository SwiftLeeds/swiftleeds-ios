import SwiftUI

extension ShapeStyle where Self == AnyShapeStyle {
    /// The fill of an avatar's fallback and skeleton.
    static var avatarFill: AnyShapeStyle { AnyShapeStyle(.fill.secondary) }
}
