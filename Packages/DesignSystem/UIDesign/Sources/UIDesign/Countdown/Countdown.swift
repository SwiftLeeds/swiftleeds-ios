import Foundation
import SwiftUI

/// A view that shows the time left until something starts.
///
/// A countdown words the time in days, hours or minutes, such as "in 12 min". From the last
/// minute before the start, and after it, it reads "now".
///
/// You create a countdown with the moment it counts to.
///
/// ```swift
/// Countdown(to: session.start)
/// ```
///
/// A countdown is essential content, so it grows with the text size. It draws no color of
/// its own: it takes the font and color of the view around it.
///
/// A countdown is not a control. A screen that shows an action should not hide it when the
/// countdown reads "now".
public struct Countdown: View {
    /// A view that draws a countdown in a given style.
    private struct ResolvedCountdownStyle<Style: CountdownStyle>: View {
        /// The style that draws the countdown.
        let style: Style

        /// The properties of the countdown.
        let configuration: CountdownStyleConfiguration

        var body: some View {
            style.makeBody(configuration: configuration)
        }
    }

    /// The current countdown style.
    @Environment(\.countdownStyle) private var style

    /// The moment the countdown counts from.
    @Environment(\.countdownNow) private var now

    /// The moment the countdown counts to.
    private let start: Date

    /// Creates a countdown to a start.
    ///
    /// - Parameter start: The moment the countdown counts to.
    public init(to start: Date) {
        self.start = start
    }

    public var body: some View {
        AnyView(resolved(in: style))
    }

    /// The properties handed to the current countdown style.
    private var configuration: CountdownStyleConfiguration {
        CountdownStyleConfiguration(label: now.text(counting: CountdownFormatStyle(to: start)))
    }

    /// Returns a view that draws the countdown in the given style.
    ///
    /// - Parameter style: The style to draw the countdown in.
    /// - Returns: A view that draws the countdown in `style`.
    private func resolved(in style: some CountdownStyle) -> some View {
        ResolvedCountdownStyle(style: style, configuration: configuration)
    }
}
