import SwiftUI

/// The default nameplate style, which draws a row with the title in the
/// headline text style.
///
/// You can also use ``NameplateStyle/automatic`` to construct this style.
public struct DefaultNameplateStyle: NameplateStyle {
    /// Creates a default nameplate style.
    public init() {}

    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        AdaptiveNameplate(configuration: configuration, titleFont: .headline)
    }
}

public extension NameplateStyle where Self == DefaultNameplateStyle {
    /// The default nameplate style, which draws a row with the title in the
    /// headline text style.
    static var automatic: DefaultNameplateStyle { DefaultNameplateStyle() }
}
