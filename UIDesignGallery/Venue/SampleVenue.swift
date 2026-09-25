import Foundation

/// The venue made up for the gallery.
///
/// Every value is display text rather than a domain value, for the reason
/// `SampleSession` gives. The address has not been checked against the venue.
enum SampleVenue {
    /// What the venue is called.
    static let name = "Leeds Playhouse"

    /// How warm it is at the venue, as the heading prints it.
    static let temperature = "18°"

    /// The SF Symbol for the weather that temperature goes with.
    static let weatherSymbol = "sun.max"

    /// The weather in words, for a person who cannot see the symbol.
    static let weather = "Sunny, 18 degrees"

    /// Where to find the rooms once a person is inside.
    static let rooms = "Main Hall and Studio are both off the first-floor foyer."

    /// What the venue serves while the schedule pauses.
    static let breaks = "Food and drink are served in the venue during every break."

    /// What lunch is, which is the one thing a person carries to it.
    static let lunch = "Lunch is a paper voucher for the food market."

    /// What the lunch notice offers to do about that.
    static let lunchAction = "Directions to the food market"
}
