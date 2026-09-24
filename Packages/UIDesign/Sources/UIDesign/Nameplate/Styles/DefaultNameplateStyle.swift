import SwiftUI

/// Draws a nameplate as a row, with the title in the weight a list row uses.
public struct DefaultNameplateStyle: NameplateStyle {
    /// Creates the style.
    public init() {}

    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        AdaptiveNameplate(configuration: configuration, titleFont: .headline)
    }
}

public extension NameplateStyle where Self == DefaultNameplateStyle {
    /// A row, which is how a nameplate draws unless a style says otherwise.
    static var automatic: DefaultNameplateStyle { DefaultNameplateStyle() }
}
