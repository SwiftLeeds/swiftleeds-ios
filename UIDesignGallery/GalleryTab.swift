import Foundation

/// One of the gallery's top-level destinations.
///
/// The raw value is what the `-tab` launch argument accepts.
enum GalleryTab: String {
    /// The conference's sessions, a day at a time.
    case schedule

    /// The venue and how to reach it.
    case venue

    /// The companies that pay for the conference.
    case sponsors

    /// Search across every destination.
    case search

    /// The SF Symbol that names this destination in the tab bar.
    var symbol: String {
        switch self {
        case .schedule: "calendar"
        case .venue: "mappin.and.ellipse"
        case .sponsors: "building.2"
        case .search: "magnifyingglass"
        }
    }

    /// The word this destination shows under its symbol.
    var title: String {
        switch self {
        case .schedule: "Schedule"
        case .venue: "Venue"
        case .sponsors: "Sponsors"
        case .search: "Search"
        }
    }
}
