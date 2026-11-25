#if os(iOS)
import Foundation

/// A distance or a count in modules, the squares a code is drawn from.
///
/// ```swift
/// let finderCenter: Modules = 7.5
/// let pixels = finderCenter.length(onSideMeasuring: 370, holding: 37)  // 75.0
/// ```
struct Modules: Equatable, Hashable, Sendable, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
    /// The number of modules.
    fileprivate let count: Double

    /// Creates a distance of a whole number of modules.
    ///
    /// - Parameter count: The number of modules.
    init(_ count: Int) {
        self.count = Double(count)
    }

    /// Creates a distance from an integer literal.
    ///
    /// - Parameter value: The number of modules.
    init(integerLiteral value: Int) {
        count = Double(value)
    }

    /// Creates a distance from a floating-point literal.
    ///
    /// - Parameter value: The number of modules.
    init(floatLiteral value: Double) {
        count = value
    }

    /// Creates a distance from a number of modules that may be a fraction.
    ///
    /// - Parameter count: The number of modules.
    private init(count: Double) {
        self.count = count
    }

    /// Returns the distance of two distances added together.
    ///
    /// - Parameters:
    ///   - lhs: The first distance.
    ///   - rhs: The second distance.
    /// - Returns: The sum of `lhs` and `rhs`.
    static func + (lhs: Self, rhs: Self) -> Self {
        Self(count: lhs.count + rhs.count)
    }

    /// Returns the distance left when one distance is taken from another.
    ///
    /// - Parameters:
    ///   - lhs: The distance to take from.
    ///   - rhs: The distance to take.
    /// - Returns: The difference of `lhs` and `rhs`.
    static func - (lhs: Self, rhs: Self) -> Self {
        Self(count: lhs.count - rhs.count)
    }

    /// Returns the length this distance covers on a side that holds a number of modules.
    ///
    /// - Parameters:
    ///   - extent: The length of the whole side, in pixels or points.
    ///   - total: The modules the whole side holds.
    /// - Returns: The length of this distance, in the unit of `extent`.
    func length(onSideMeasuring extent: Double, holding total: Self) -> Double {
        count * extent / total.count
    }

    /// Returns the whole pixels each module takes on a side that holds this many modules.
    ///
    /// - Parameter pixels: The length of the whole side, in pixels.
    /// - Returns: The pixels for each module, with any remainder dropped.
    func wholePixelsPerModule(onSideMeasuring pixels: Int) -> Int {
        pixels / Int(count)
    }

    /// Returns the pixels this many modules take at a number of pixels for each module.
    ///
    /// - Parameter pixelsPerModule: The pixels each module takes.
    /// - Returns: The pixels of the whole side.
    func pixels(atPixelsPerModule pixelsPerModule: Int) -> Int {
        Int(count) * pixelsPerModule
    }
}
#endif
