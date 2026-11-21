import Foundation
import SwiftUI

/// The moment a countdown counts from: the clock, a test or a preview.
package struct CountdownNow: Equatable, Hashable, Sendable {
    /// Where the moment comes from.
    private enum Source: Equatable, Hashable, Sendable {
        /// The system clock.
        case live
        /// A moment set by the caller.
        case fixed(Date)
    }

    /// The moment that the system clock reads.
    package static let live = Self(source: .live)

    /// Where the moment comes from.
    private let source: Source

    /// Returns a moment that never moves.
    ///
    /// - Parameter date: The moment the clock reads.
    /// - Returns: A moment fixed at `date`.
    package static func fixed(_ date: Date) -> Self {
        Self(source: .fixed(date))
    }

    /// Returns a text that words the time left from this moment.
    ///
    /// - Parameter format: The format style that words the time left.
    /// - Returns: A text that follows the system clock for the live moment, or a text drawn once
    ///   for a fixed one.
    package func text(counting format: CountdownFormatStyle) -> Text {
        switch source {
        case .live: Text(.currentDate, format: format)
        case .fixed(let date): Text(date, format: format)
        }
    }
}
