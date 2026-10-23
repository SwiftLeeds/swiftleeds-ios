import Foundation

/// A place to reach a team member online.
public enum SocialLink: Equatable, Hashable, Sendable {
    /// A link to the member on LinkedIn.
    case linkedIn(URL)

    /// A link to the member on Twitter.
    case twitter(URL)

    /// A link to the member on Slack.
    case slack(URL)
}
