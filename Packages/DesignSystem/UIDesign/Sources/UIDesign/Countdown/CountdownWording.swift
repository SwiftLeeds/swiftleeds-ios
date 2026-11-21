import Foundation

/// How a countdown words the time left.
enum CountdownWording: Sendable {
    /// Abbreviated words for the screen, such as "in 12 min".
    case shown

    /// Full words for VoiceOver, such as "in 12 minutes".
    case spoken

    /// The units style that draws the words.
    var unitsStyle: Date.AnchoredRelativeFormatStyle.UnitsStyle {
        switch self {
        case .shown: .abbreviated
        case .spoken: .wide
        }
    }
}
