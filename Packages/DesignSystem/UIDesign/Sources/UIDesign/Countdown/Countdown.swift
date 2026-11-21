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
        AnyView(style.makeBody(configuration: configuration))
    }

    /// The properties handed to the current countdown style.
    private var configuration: CountdownStyleConfiguration {
        CountdownStyleConfiguration(label: now.text(counting: CountdownFormatStyle(to: start)))
    }
}
