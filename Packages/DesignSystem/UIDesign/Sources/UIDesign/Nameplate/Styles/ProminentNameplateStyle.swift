import SwiftUI

/// A nameplate style that draws a heading, with the title in the title 3 text
/// style and vertical padding around the row.
///
/// You can also use ``NameplateStyle/prominent`` to construct this style.
///
/// Use it for the one nameplate that names what a screen is about, such as the
/// account a settings screen belongs to. Give its icon ``AvatarSize/large``.
///
/// On the Watch, the icon sits above the text, centered, and the title and the
/// detail each keep to one line.
public struct ProminentNameplateStyle: NameplateStyle {
    /// Creates a prominent nameplate style.
    public init() {}

    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        #if os(watchOS)
        StackedNameplate(configuration: configuration, titleFont: .title3.weight(.semibold))
            .padding(.vertical, .sm)
        #else
        AdaptiveNameplate(configuration: configuration, titleFont: .title3.weight(.semibold))
            .padding(.vertical, .sm)
        #endif
    }
}

extension NameplateStyle where Self == ProminentNameplateStyle {
    /// A nameplate style that draws a heading, with the title in the title 3
    /// text style and vertical padding around the row.
    public static var prominent: ProminentNameplateStyle { ProminentNameplateStyle() }
}
