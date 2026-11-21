import Foundation

/// A format style that words the time left until a start.
///
/// The words are abbreviated and counted in days, hours or minutes, such as "in 12 min".
///
/// In a `Text`, the format takes the view's locale, but not its time zone. Set another time
/// zone with ``CountdownFormatStyle/calendar(_:)``.
///
/// ```swift
/// let style = CountdownFormatStyle(to: start)
/// style.format(start.addingTimeInterval(-12 * 60))  // "in 12 min"
/// ```
public struct CountdownFormatStyle: DiscreteFormatStyle, Equatable, Hashable, Sendable {
    /// The time before the start, in seconds, from which the words read "now".
    private static let lastMinute: TimeInterval = 60

    /// The relative style that words the time, anchored at the start.
    private var relative: Date.AnchoredRelativeFormatStyle

    /// The moment the countdown runs to.
    private var start: Date { relative.anchor }

    /// The relative style that words "now", in the language of the locale.
    private var nowWord: Date.AnchoredRelativeFormatStyle {
        var word = Date.AnchoredRelativeFormatStyle(
            anchor: start,
            presentation: .named,
            unitsStyle: relative.unitsStyle,
        )
        word.locale = relative.locale
        word.calendar = relative.calendar
        return word
    }

    /// The first moment that reads "now".
    private var lastMinuteStart: Date {
        start.addingTimeInterval(-Self.lastMinute)
    }

    /// Creates a format style that words the time left until a start.
    ///
    /// ```swift
    /// let style = CountdownFormatStyle(to: start)
    /// style.format(start.addingTimeInterval(-12 * 60))  // "in 12 min"
    /// ```
    ///
    /// - Parameter start: The moment the countdown runs to.
    public init(to start: Date) {
        self.init(to: start, wording: .shown)
    }

    /// Creates a format style that words the time left until a start.
    ///
    /// - Parameters:
    ///   - start: The moment the countdown runs to.
    ///   - wording: Whether to word the time in short words for the screen or in full for VoiceOver.
    init(to start: Date, wording: CountdownWording) {
        relative = Date.AnchoredRelativeFormatStyle(
            anchor: start,
            allowedFields: [.day, .hour, .minute],
            presentation: .numeric,
            unitsStyle: wording.unitsStyle,
        )
    }

    /// Creates a format style from an encoded one.
    ///
    /// - Parameter decoder: The decoder to read the style from.
    /// - Throws: An error if the data is not an encoded format style.
    public init(from decoder: any Decoder) throws {
        relative = try decoder.singleValueContainer().decode(Date.AnchoredRelativeFormatStyle.self)
    }

    /// Encodes the style, with the moment it counts to, its wording, locale and calendar.
    ///
    /// - Parameter encoder: The encoder to write the style to.
    /// - Throws: An error if the encoder cannot write the style.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(relative)
    }

    /// Returns the words for the time left from a moment until the start.
    ///
    /// It reads "now" from the last minute before the start, and after it.
    ///
    /// ```swift
    /// let style = CountdownFormatStyle(to: start)
    /// style.format(start.addingTimeInterval(-12 * 60))  // "in 12 min"
    /// style.format(start.addingTimeInterval(-30))  // "now"
    /// ```
    ///
    /// - Parameter now: The moment to count from.
    /// - Returns: The time left, such as "in 12 min", or "now".
    public func format(_ now: Date) -> String {
        guard now < lastMinuteStart else { return nowWord.format(start) }
        return relative.format(now)
    }

    /// Returns a copy that words the time in a locale.
    ///
    /// ```swift
    /// let style = CountdownFormatStyle(to: start).locale(Locale(identifier: "de_DE"))
    /// style.format(start.addingTimeInterval(-12 * 60))  // "in 12 Min."
    /// ```
    ///
    /// - Parameter locale: The locale that decides the language of the words.
    /// - Returns: A format style that uses `locale`.
    public func locale(_ locale: Locale) -> Self {
        var copy = self
        copy.relative.locale = locale
        return copy
    }

    /// Returns a copy that counts days in a calendar.
    ///
    /// ```swift
    /// var calendar = Calendar(identifier: .gregorian)
    /// calendar.timeZone = .gmt
    /// let style = CountdownFormatStyle(to: start).calendar(calendar)  // counts days in GMT
    /// ```
    ///
    /// - Parameter calendar: The calendar, with its time zone, that decides where a day starts.
    /// - Returns: A format style that uses `calendar`.
    public func calendar(_ calendar: Calendar) -> Self {
        var copy = self
        copy.relative.calendar = calendar
        return copy
    }

    /// Returns the last moment before a moment that reads differently from it.
    ///
    /// ```swift
    /// let style = CountdownFormatStyle(to: start)
    /// let now = start.addingTimeInterval(-12 * 60)
    /// let earlier = style.discreteInput(before: now)  // the last moment that reads "in 13 min"
    /// ```
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
    /// ```swift
    /// let style = CountdownFormatStyle(to: start)
    /// style.discreteInput(after: start.addingTimeInterval(-61))  // start - 60 s, where it reads "now"
    /// style.discreteInput(after: start)  // nil
    /// ```
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
    /// In a `Text`, the format takes the view's locale, but not its time zone. Set another time
    /// zone with ``CountdownFormatStyle/calendar(_:)``.
    ///
    /// ```swift
    /// Text(.currentDate, format: .countdown(to: session.start))  // "in 12 min"
    /// ```
    ///
    /// - Parameter start: The moment the countdown runs to.
    /// - Returns: A format style that counts down to `start`.
    public static func countdown(to start: Date) -> CountdownFormatStyle {
        CountdownFormatStyle(to: start)
    }
}
