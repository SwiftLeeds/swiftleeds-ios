import SwiftUI

/// A view that stands in for a nameplate while its subject loads.
///
/// Put one where each nameplate will be, so the screen does not move when the
/// subjects arrive.
///
/// ```swift
/// ForEach(0 ..< 5, id: \.self) { _ in
///     NameplatePlaceholder()
/// }
/// ```
///
/// A placeholder takes the current ``NameplateStyle``, so its title and its
/// spacing match the rows it stands in for. Its icon does not, so give it the
/// size the real nameplate will use.
///
/// VoiceOver skips it. Say that a screen is loading from the screen itself,
/// where you can use words a listener can act on.
public struct NameplatePlaceholder: View {
    /// The diameter of the circle standing in for the icon.
    private let size: AvatarSize

    /// Creates a placeholder for a nameplate.
    ///
    /// - Parameter size: The diameter the real nameplate's icon will have. The
    ///   default is ``AvatarSize/medium``, which is the size a row uses.
    public init(size: AvatarSize = .medium) {
        self.size = size
    }

    public var body: some View {
        Nameplate(Self.titleBar, detail: Self.detailBar) {
            // A flat fill rather than an empty view: an avatar draws its
            // content over nothing, so an empty slot would leave a hole where
            // the redacted circle belongs.
            Avatar(url: nil, size: size) { Color.secondarySurface }
        }
        .redacted(reason: .placeholder)
        .accessibilityHidden(true)
    }

    /// How wide the bar standing in for the title is, in box drawing
    /// characters. Redaction replaces them before anyone sees them.
    private static let titleBar = "──────────"

    /// How wide the bar standing in for the detail is.
    private static let detailBar = "────────────"
}

#Preview("Loading") {
    VStack(spacing: .large) {
        NameplatePlaceholder()
        NameplatePlaceholder()
        NameplatePlaceholder()
    }
    .padding(.large)
}

#Preview("Loading a heading") {
    NameplatePlaceholder(size: .large)
        .nameplateStyle(.prominent)
        .padding(.large)
}
