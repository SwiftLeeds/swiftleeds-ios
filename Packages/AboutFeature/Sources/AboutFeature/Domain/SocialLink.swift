import Foundation

/// A place to reach a team member online.
public enum SocialLink: Equatable, Hashable, Sendable {
    case linkedIn(URL)
    case twitter(URL)
    case slack(URL)
}
