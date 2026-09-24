import SwiftUI

/// A nameplate style that draws a heading, with the title in the title 3 text
/// style and vertical padding around the row.
///
/// You can also use ``NameplateStyle/prominent`` to construct this style.
///
/// Use it for the one nameplate that names what a screen is about, such as the
/// account a settings screen belongs to. Give its icon ``AvatarSize/large``.
public struct ProminentNameplateStyle: NameplateStyle {
    /// Creates a prominent nameplate style.
    public init() {}

    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        AdaptiveNameplate(configuration: configuration, titleFont: .title3.weight(.semibold))
            .padding(.vertical, .small)
    }
}

public extension NameplateStyle where Self == ProminentNameplateStyle {
    /// A nameplate style that draws a heading, with the title in the title 3
    /// text style and vertical padding around the row.
    static var prominent: ProminentNameplateStyle { ProminentNameplateStyle() }
}
