import SwiftUI

/// A nameplate style that draws a row, with the title in a list row's weight.
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
    /// A nameplate style that draws a row, with the title in a list row's
    /// weight.
    static var automatic: DefaultNameplateStyle { DefaultNameplateStyle() }
}
