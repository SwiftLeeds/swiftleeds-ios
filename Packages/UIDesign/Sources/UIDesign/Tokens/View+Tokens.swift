import SwiftUI

// Only for modifiers whose whole purpose is a length. A length among other arguments, such as
// `Grid` or `strokeBorder`, uses `CGFloat(token)` at the call site.

extension View {
    /// Adds a space around this view.
    public func padding(_ spacing: Spacing) -> some View {
        padding(CGFloat(spacing))
    }

    /// Adds a space along the given edges of this view.
    public func padding(_ edges: Edge.Set, _ spacing: Spacing) -> some View {
        padding(edges, CGFloat(spacing))
    }

    /// Fixes this view to the size of an icon.
    public func frame(_ size: IconSize, alignment: Alignment = .center) -> some View {
        frame(width: CGFloat(size), height: CGFloat(size), alignment: alignment)
    }

    /// Fixes this view to the size of an avatar.
    public func frame(_ size: AvatarSize, alignment: Alignment = .center) -> some View {
        frame(width: CGFloat(size), height: CGFloat(size), alignment: alignment)
    }
}

extension HStack {
    /// Creates a horizontal stack with a space between its views.
    public init(
        alignment: VerticalAlignment = .center,
        spacing: Spacing,
        @ViewBuilder content: () -> Content
    ) {
        self.init(alignment: alignment, spacing: CGFloat(spacing), content: content)
    }
}

extension VStack {
    /// Creates a vertical stack with a space between its views.
    public init(
        alignment: HorizontalAlignment = .center,
        spacing: Spacing,
        @ViewBuilder content: () -> Content
    ) {
        self.init(alignment: alignment, spacing: CGFloat(spacing), content: content)
    }
}
