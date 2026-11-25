/// A place in a rendered image, counted in whole pixels.
///
/// ```swift
/// let position = PixelPosition(column: 3, row: 0)  // the fourth pixel of the top row
/// ```
package struct PixelPosition: Equatable, Hashable, Sendable {
    /// The column of the pixel, from the left.
    package let column: Int

    /// The row of the pixel, from the top.
    package let row: Int

    /// Creates a position.
    ///
    /// - Parameters:
    ///   - column: The column of the pixel, from the left.
    ///   - row: The row of the pixel, from the top.
    package init(column: Int, row: Int) {
        self.column = column
        self.row = row
    }
}
