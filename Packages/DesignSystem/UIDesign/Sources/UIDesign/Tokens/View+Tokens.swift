import SwiftUI

// Each overload lets a call site name a token where Apple's API takes a number, as in
// `.padding(.large)`.

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
        @ViewBuilder content: () -> Content,
    ) {
        self.init(alignment: alignment, spacing: CGFloat(spacing), content: content)
    }
}

extension VStack {
    /// Creates a vertical stack with a space between its views.
    public init(
        alignment: HorizontalAlignment = .center,
        spacing: Spacing,
        @ViewBuilder content: () -> Content,
    ) {
        self.init(alignment: alignment, spacing: CGFloat(spacing), content: content)
    }
}

extension HStackLayout {
    /// Creates a horizontal stack with the specified spacing and vertical alignment.
    ///
    /// - Parameters:
    ///   - alignment: The guide for aligning the subviews in this stack. It has the same
    ///     vertical screen coordinate for all subviews. The default is `.center`.
    ///   - spacing: The distance between adjacent subviews.
    public init(alignment: VerticalAlignment = .center, spacing: Spacing) {
        self.init(alignment: alignment, spacing: CGFloat(spacing))
    }
}

extension VStackLayout {
    /// Creates a vertical stack with the specified spacing and horizontal alignment.
    ///
    /// - Parameters:
    ///   - alignment: The guide for aligning the subviews in this stack. It has the same
    ///     horizontal screen coordinate for all subviews. The default is `.center`.
    ///   - spacing: The distance between adjacent subviews.
    public init(alignment: HorizontalAlignment = .center, spacing: Spacing) {
        self.init(alignment: alignment, spacing: CGFloat(spacing))
    }
}

extension Grid {
    /// Creates a grid with the specified spacing, alignment, and child views.
    ///
    /// - Parameters:
    ///   - alignment: The guide for aligning the child views within the space allocated for a
    ///     given cell. The default is `.center`.
    ///   - horizontalSpacing: The horizontal distance between each cell.
    ///   - verticalSpacing: The vertical distance between each cell.
    ///   - content: A closure that creates the grid's rows.
    public init(
        alignment: Alignment = .center,
        horizontalSpacing: Spacing,
        verticalSpacing: Spacing,
        @ViewBuilder content: () -> Content,
    ) {
        self.init(
            alignment: alignment,
            horizontalSpacing: CGFloat(horizontalSpacing),
            verticalSpacing: CGFloat(verticalSpacing),
            content: content,
        )
    }
}
