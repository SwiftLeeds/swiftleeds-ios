import SwiftUI

/// The shape of a ``Nameplate``, drawn while the real one is still loading.
///
/// Put one where each nameplate will be, so the screen does not move when the subjects arrive.
///
/// ```swift
/// ForEach(0 ..< 5, id: \.self) { _ in
///     NameplatePlaceholder()
/// }
/// ```
///
/// It takes whichever ``NameplateStyle`` is in force, so it matches the rows it stands in for.
///
/// VoiceOver skips it. Say that the screen is loading from the screen itself, where you can use
/// words a listener can act on.
public struct NameplatePlaceholder: View {
    /// Creates a placeholder.
    public init() {}

    public var body: some View {
        Nameplate {
            Text(verbatim: Self.titleBar)
        } detail: {
            Text(verbatim: Self.detailBar)
        } icon: {
            // A flat fill rather than an empty view: an avatar draws its content over nothing, so
            // an empty slot would leave a hole where the redacted circle belongs.
            Avatar(url: nil) { Color.secondarySurface }
        }
        .redacted(reason: .placeholder)
        .accessibilityHidden(true)
    }

    // Box drawing, never an em dash. The characters only set how wide each bar is: redaction
    // replaces them before anyone sees them. The builder initializer keeps them out of the
    // localized initializer, which a literal would otherwise reach.
    private static let titleBar = "──────────"
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
