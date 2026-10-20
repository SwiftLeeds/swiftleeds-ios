import SwiftUI

/// A layout that puts its subviews in two equal columns, or in one column when
/// a subview does not fit in half the width.
struct EqualColumns: Layout {
    /// The space between the two columns, in points.
    let columnGap: CGFloat

    /// The space between one row and the next, in points.
    let rowGap: CGFloat

    /// Returns how many columns the subviews use at a width.
    ///
    /// - Parameters:
    ///   - width: The width the subviews share.
    ///   - subviews: The subviews to place.
    /// - Returns: The number of columns, 1 or 2.
    private func columnCount(for width: CGFloat, subviews: Subviews) -> Int {
        let count = min(subviews.count, 2)
        guard count > 1 else { return 1 }
        let columnWidth = (width - columnGap * CGFloat(count - 1)) / CGFloat(count)
        let fits = subviews.allSatisfy { $0.sizeThatFits(.unspecified).width <= columnWidth }
        return fits ? count : 1
    }

    /// Returns where each subview sits at a width, and how tall they are
    /// together.
    ///
    /// - Parameters:
    ///   - width: The width the subviews share.
    ///   - subviews: The subviews to place.
    /// - Returns: The frame of each subview, and the height of all of them together.
    private func arrange(
        width: CGFloat,
        subviews: Subviews,
    ) -> (frames: [CGRect], height: CGFloat) {
        let columns = columnCount(for: width, subviews: subviews)
        let columnWidth = (width - columnGap * CGFloat(columns - 1)) / CGFloat(columns)
        let proposal = ProposedViewSize(width: columnWidth, height: nil)
        var frames: [CGRect] = []
        var top: CGFloat = 0
        var first = 0
        while first < subviews.count {
            let row = subviews[first..<min(first + columns, subviews.count)]
            let height = row.map { $0.sizeThatFits(proposal).height }.max() ?? 0
            for column in 0..<row.count {
                let left = CGFloat(column) * (columnWidth + columnGap)
                frames.append(CGRect(x: left, y: top, width: columnWidth, height: height))
            }
            top += height + rowGap
            first += columns
        }
        return (frames, max(top - rowGap, 0))
    }

    /// The size the columns take, as wide as the proposal allows.
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout (),
    ) -> CGSize {
        let widths = subviews.map { $0.sizeThatFits(.unspecified).width }
        let gaps = columnGap * CGFloat(max(subviews.count - 1, 0))
        let width = proposal.width ?? widths.reduce(0, +) + gaps
        return CGSize(width: width, height: arrange(width: width, subviews: subviews).height)
    }

    /// Places each subview in its column and row.
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout (),
    ) {
        let frames = arrange(width: bounds.width, subviews: subviews).frames
        for (subview, frame) in zip(subviews, frames) {
            subview.place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: frame.width, height: nil),
            )
        }
    }
}
