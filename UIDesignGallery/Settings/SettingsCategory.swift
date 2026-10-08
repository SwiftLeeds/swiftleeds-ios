/// A part of Settings that a row in the root opens.
///
/// The raw value is what the `-category` launch argument accepts. Every
/// field is display text rather than a domain value, for the reason
/// `SampleSession` gives.
enum SettingsCategory: String, CaseIterable, Equatable, Hashable {
    /// How the app looks on this person's device.
    case appearance

    /// What the app tells this person about before it happens.
    case notifications

    /// Who runs the conference, and where it publishes.
    case about

    /// How to reach the people who run the conference.
    case contact

    /// What the row and the screen call it.
    var title: String {
        switch self {
        case .appearance: "Appearance"
        case .notifications: "Notifications"
        case .about: "About"
        case .contact: "Contact us"
        }
    }

    /// The SF Symbol that stands for it.
    var symbol: String {
        switch self {
        case .appearance: "paintpalette.fill"
        case .notifications: "bell.badge.fill"
        case .about: "info.circle.fill"
        case .contact: "envelope.fill"
        }
    }

    /// One sentence saying what its screen is for.
    var detail: String {
        switch self {
        case .appearance: "Choose the icon the app shows on your Home Screen."
        case .notifications: "Hear about the sessions you've saved before they start."
        case .about: "Who runs SwiftLeeds, and where to find us online."
        case .contact: "Ways to reach the organizers before, during and after the conference."
        }
    }
}
