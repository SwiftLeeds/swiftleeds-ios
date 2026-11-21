import SwiftUI

extension ShapeStyle where Self == AnyShapeStyle {
    /// The fill that stands in for content that is missing or still loading.
    static var secondaryFill: AnyShapeStyle { AnyShapeStyle(.fill.secondary) }

    /// The fill of an avatar's fallback and skeleton.
    static var avatarFill: AnyShapeStyle { .secondaryFill }
}
