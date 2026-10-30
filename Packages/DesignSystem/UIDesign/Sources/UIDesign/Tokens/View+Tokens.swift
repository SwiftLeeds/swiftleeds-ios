import SwiftUI

extension View {
    /// Adds an equal padding amount to all edges of this view.
    ///
    /// - Parameter spacing: The amount to pad this view on each edge.
    /// - Returns: A view that's padded by the specified amount on all edges.
    public func padding(_ spacing: Spacing) -> some View {
        padding(CGFloat(spacing))
    }

    /// Adds an equal padding amount to specific edges of this view.
    ///
    /// - Parameters:
    ///   - edges: The set of edges to pad for this view.
    ///   - spacing: The amount to pad this view on the specified edges.
    /// - Returns: A view that's padded by the specified amount on the specified edges.
    public func padding(_ edges: Edge.Set, _ spacing: Spacing) -> some View {
        padding(edges, CGFloat(spacing))
    }

    /// Positions this view within an invisible frame with the size of an icon.
    ///
    /// - Parameters:
    ///   - size: The icon size to use for the frame's width and height.
    ///   - alignment: The alignment of this view inside the resulting frame. The default is
    ///     `.center`.
    /// - Returns: A view with fixed dimensions of the icon size.
    public func frame(_ size: IconSize, alignment: Alignment = .center) -> some View {
        frame(width: CGFloat(size), height: CGFloat(size), alignment: alignment)
    }

    /// Positions this view within an invisible frame with the size of an avatar.
    ///
    /// - Parameters:
    ///   - size: The avatar size to use for the frame's width and height.
    ///   - alignment: The alignment of this view inside the resulting frame. The default is
    ///     `.center`.
    /// - Returns: A view with fixed dimensions of the avatar size.
    public func frame(_ size: AvatarSize, alignment: Alignment = .center) -> some View {
        frame(width: CGFloat(size), height: CGFloat(size), alignment: alignment)
    }
}

extension HStack {
    /// Creates a horizontal stack with the given spacing and vertical alignment.
    ///
    /// - Parameters:
    ///   - alignment: The guide for aligning the subviews in this stack. This guide has the same
    ///     vertical screen coordinate for every subview. The default is `.center`.
    ///   - spacing: The distance between adjacent subviews.
    ///   - content: A content builder that creates the content of this stack.
    public init(
        alignment: VerticalAlignment = .center,
        spacing: Spacing,
        @ViewBuilder content: () -> Content,
    ) {
        self.init(alignment: alignment, spacing: CGFloat(spacing), content: content)
    }
}

extension VStack {
    /// Creates an instance with the given spacing and horizontal alignment.
    ///
    /// - Parameters:
    ///   - alignment: The guide for aligning the subviews in this stack. This guide has the same
    ///     horizontal screen coordinate for every subview. The default is `.center`.
    ///   - spacing: The distance between adjacent subviews.
    ///   - content: A content builder that creates the content of this stack.
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
