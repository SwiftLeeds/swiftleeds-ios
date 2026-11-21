import SwiftUI

extension ShapeStyle where Self == AnyShapeStyle {
    /// The fill for medium-size shapes.
    static var secondaryFill: AnyShapeStyle { AnyShapeStyle(.fill.secondary) }

    /// A second name for ``secondaryFill``.
    static var avatarFill: AnyShapeStyle { .secondaryFill }
}
