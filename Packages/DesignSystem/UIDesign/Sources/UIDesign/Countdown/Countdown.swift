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
/// VoiceOver reads the time in full, such as "in 12 minutes", and treats the text as one that
/// updates often, so it does not announce each change. A redacted countdown is hidden from
/// VoiceOver.
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

    /// The current calendar.
    @Environment(\.calendar) private var calendar

    /// The current time zone.
    @Environment(\.timeZone) private var timeZone

    /// The moment the countdown counts to.
    private let start: Date

    /// Creates a countdown to a start.
    ///
    /// - Parameter start: The moment the countdown counts to.
    public init(to start: Date) {
        self.start = start
    }

    /// The countdown, with a spoken label and the trait of text that updates often.
    public var body: some View {
        AnyView(resolved(in: style))
            .accessibilityLabel(now.text(counting: formatStyle(wording: .spoken)))
            .accessibilityAddTraits(.updatesFrequently)
    }

    /// The properties handed to the current countdown style.
    private var configuration: CountdownStyleConfiguration {
        CountdownStyleConfiguration(label: now.text(counting: formatStyle(wording: .shown)))
    }

    /// The calendar the countdown counts days in: the current calendar, in the current time zone.
    private var countingCalendar: Calendar {
        var counting = calendar
        counting.timeZone = timeZone
        return counting
    }

    /// Returns the format style that words the time left.
    ///
    /// - Parameter wording: Whether to word the time in short words for the screen or in full.
    /// - Returns: A format style that counts days in the current calendar and time zone.
    private func formatStyle(wording: CountdownWording) -> CountdownFormatStyle {
        CountdownFormatStyle(to: start, wording: wording).calendar(countingCalendar)
    }

    /// Returns a view that draws the countdown in the given style.
    ///
    /// - Parameter style: The style to draw the countdown in.
    /// - Returns: A view that draws the countdown in `style`.
    private func resolved(in style: some CountdownStyle) -> some View {
        ResolvedCountdownStyle(style: style, configuration: configuration)
    }
}

#Preview("Times left") {
    let start = Date(timeIntervalSinceReferenceDate: 800_000_000)
    return VStack(alignment: .leading, spacing: .md) {
        ForEach([12 * 60, 2 * 60 * 60, 30], id: \.self) { secondsLeft in
            Countdown(to: start)
                .countdownNow(.fixed(start.addingTimeInterval(-TimeInterval(secondsLeft))))
        }
    }
    .environment(\.locale, Locale(identifier: "en_GB"))
    .padding(.lg)
}
