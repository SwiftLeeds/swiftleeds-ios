import SwiftUI

// Overloads for the modifiers whose whole purpose is a length, so a token reaches them without
// being unwrapped at the call site. Anything that takes a length among other arguments, such as
// `Grid` or `strokeBorder`, uses `CGFloat(token)` instead.

public extension View {
    /// Adds a space around this view.
    func padding(_ spacing: Spacing) -> some View {
        padding(CGFloat(spacing))
    }

    /// Adds a space along the given edges of this view.
    func padding(_ edges: Edge.Set, _ spacing: Spacing) -> some View {
        padding(edges, CGFloat(spacing))
    }

    /// Fixes this view to the size of an icon.
    func frame(_ size: IconSize, alignment: Alignment = .center) -> some View {
        frame(width: CGFloat(size), height: CGFloat(size), alignment: alignment)
    }

    /// Fixes this view to the size of an avatar.
    func frame(_ size: AvatarSize, alignment: Alignment = .center) -> some View {
        frame(width: CGFloat(size), height: CGFloat(size), alignment: alignment)
    }
}

public extension HStack {
    /// Creates a horizontal stack with a space between its views.
    init(
        alignment: VerticalAlignment = .center,
        spacing: Spacing,
        @ViewBuilder content: () -> Content
    ) {
        self.init(alignment: alignment, spacing: CGFloat(spacing), content: content)
    }
}

public extension VStack {
    /// Creates a vertical stack with a space between its views.
    init(
        alignment: HorizontalAlignment = .center,
        spacing: Spacing,
        @ViewBuilder content: () -> Content
    ) {
        self.init(alignment: alignment, spacing: CGFloat(spacing), content: content)
    }
}
