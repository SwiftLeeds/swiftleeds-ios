import SwiftUI

/// Draws a nameplate as a heading, with a larger title and room above and below it.
///
/// Use it for the one nameplate that names what a screen is about, such as the account a settings
/// screen belongs to. Give its icon ``AvatarSize/large``.
public struct ProminentNameplateStyle: NameplateStyle {
    /// Creates the style.
    public init() {}

    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        AdaptiveNameplate(configuration: configuration, titleFont: .title3.weight(.semibold))
            .padding(.vertical, .small)
    }
}

public extension NameplateStyle where Self == ProminentNameplateStyle {
    /// A heading, for the nameplate that names the screen's subject.
    static var prominent: ProminentNameplateStyle { ProminentNameplateStyle() }
}
