import SwiftUI

/// The default nameplate style, which draws a row with the title in the
/// headline text style.
///
/// On the Watch, the row draws no icon, and an avatar's status shows at the
/// trailing end of the title's line.
///
/// You can also use ``NameplateStyle/automatic`` to construct this style.
public struct DefaultNameplateStyle: NameplateStyle {
    /// Creates a default nameplate style.
    public init() {}

    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        #if os(watchOS)
        TitleAndDetailNameplate(configuration: configuration, titleFont: .headline)
        #else
        AdaptiveNameplate(configuration: configuration, titleFont: .headline)
        #endif
    }
}

extension NameplateStyle where Self == DefaultNameplateStyle {
    /// The default nameplate style, which draws a row with the title in the
    /// headline text style.
    ///
    /// On the Watch, the row draws no icon, and an avatar's status shows at the
    /// trailing end of the title's line.
    public static var automatic: DefaultNameplateStyle { DefaultNameplateStyle() }
}
