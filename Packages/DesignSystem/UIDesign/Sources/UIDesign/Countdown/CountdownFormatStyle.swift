import Foundation

/// A format style that words the time left until a start.
///
/// The words are abbreviated and counted in days, hours or minutes, such as "in 12 min".
///
/// ```swift
/// let style = CountdownFormatStyle(to: start)
/// style.format(start.addingTimeInterval(-12 * 60))  // "in 12 min"
/// ```
public struct CountdownFormatStyle: DiscreteFormatStyle, Codable, Equatable, Hashable, Sendable {
    /// The time before the start from which the words read "now".
    private static let lastMinute = Duration.seconds(secondsPerMinute)

    /// The number of seconds in a minute.
    private static let secondsPerMinute = 60

    /// The moment the countdown runs to.
    private let start: Date

    /// The relative style that words the time, anchored at the start.
    private var relative: Date.AnchoredRelativeFormatStyle

    /// The relative style that words "now", in the language of the locale.
    private var nowWord: Date.AnchoredRelativeFormatStyle

    /// The first moment that reads "now".
    private var lastMinuteStart: Date {
        start.addingTimeInterval(-TimeInterval(Self.lastMinute.components.seconds))
    }

    /// Creates a format style that words the time left until a start.
    ///
    /// - Parameter start: The moment the countdown runs to.
    public init(to start: Date) {
        self.init(to: start, spoken: false)
    }

    /// Creates a format style that words the time left until a start.
    ///
    /// - Parameters:
    ///   - start: The moment the countdown runs to.
    ///   - spoken: Whether to word the time in full, such as "in 12 minutes", for VoiceOver.
    init(to start: Date, spoken: Bool) {
        let unitsStyle: Date.AnchoredRelativeFormatStyle.UnitsStyle = spoken ? .wide : .abbreviated
        self.start = start
        relative = Date.AnchoredRelativeFormatStyle(
            anchor: start,
            allowedFields: [.day, .hour, .minute],
            presentation: .numeric,
            unitsStyle: unitsStyle,
        )
        nowWord = Date.AnchoredRelativeFormatStyle(
            anchor: start,
            presentation: .named,
            unitsStyle: unitsStyle,
        )
    }

    /// Returns the words for the time left from a moment until the start.
    ///
    /// It reads "now" from the last minute before the start, and after it.
    ///
    /// - Parameter now: The moment to count from.
    /// - Returns: The abbreviated time left, such as "in 12 min", or "now".
    public func format(_ now: Date) -> String {
        guard now < lastMinuteStart else { return nowWord.format(start) }
        return relative.format(now)
    }

    /// Returns a copy that words the time in a locale.
    ///
    /// - Parameter locale: The locale that decides the language of the words.
    /// - Returns: A format style that uses `locale`.
    public func locale(_ locale: Locale) -> Self {
        var copy = self
        copy.relative.locale = locale
        copy.nowWord.locale = locale
        return copy
    }

    /// Returns a copy that counts days in a calendar.
    ///
    /// - Parameter calendar: The calendar, with its time zone, that decides where a day starts.
    /// - Returns: A format style that uses `calendar`.
    public func calendar(_ calendar: Calendar) -> Self {
        var copy = self
        copy.relative.calendar = calendar
        copy.nowWord.calendar = calendar
        return copy
    }

    /// Returns the last moment before a moment that reads differently from it.
    ///
    /// - Parameter now: The moment to look back from.
    /// - Returns: The last moment that reads differently from `now`, or `nil` if there is none.
    public func discreteInput(before now: Date) -> Date? {
        guard now < lastMinuteStart else {
            return Date(timeIntervalSinceReferenceDate: lastMinuteStart.timeIntervalSinceReferenceDate.nextDown)
        }
        return relative.discreteInput(before: now)
    }

    /// Returns the first moment after a moment at which the words change.
    ///
    /// Once the words read "now" they never change again.
    ///
    /// - Parameter now: The moment to look forward from.
    /// - Returns: The first moment that reads differently from `now`, or `nil` if none does.
    public func discreteInput(after now: Date) -> Date? {
        guard now < lastMinuteStart else { return nil }
        guard let moment = relative.discreteInput(after: now), moment < lastMinuteStart else {
            return lastMinuteStart
        }
        return moment
    }
}

extension FormatStyle where Self == CountdownFormatStyle {
    /// Returns a format style that words the time left until a start.
    ///
    /// - Parameter start: The moment the countdown runs to.
    /// - Returns: A format style that counts down to `start`.
    public static func countdown(to start: Date) -> CountdownFormatStyle {
        CountdownFormatStyle(to: start)
    }
}
