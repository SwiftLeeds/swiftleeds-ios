import AboutFeature
import Dependencies
import Foundation
import NetworkKit
import Observation

/// The About screen's state: its links and text, and the conference team.
@Observable
@MainActor
package final class AboutViewModel {
    private(set) var teamMembers: [TeamMember] = []

    private let aboutContent = AboutContent.swiftLeeds

    package init() {}

    package var venueURL: URL? {
        apiURL(path: aboutContent.links.venue)
    }

    package var codeOfConductURL: URL? {
        apiURL(path: aboutContent.links.codeOfConduct)
    }

    package var reportAProblemLink: String {
        aboutContent.links.reportAProblem
    }

    package var slackURL: URL? {
        URL(string: aboutContent.links.slack)
    }

    package var youtubeURL: URL? {
        URL(string: aboutContent.links.youtube)
    }

    var truncatedAboutText: String {
        aboutContent.truncatedAboutText
    }

    var fullAboutText: String {
        aboutContent.fullAboutText
    }

    /// Fetches the team, unless a team is already loaded.
    package func loadIfNeeded() async {
        guard teamMembers.isEmpty else { return }
        await load()
    }

    private func apiURL(path: String) -> URL? {
        @Dependency(\.apiConfiguration) var apiConfiguration
        return URL(string: path, relativeTo: apiConfiguration.baseURL)?.absoluteURL
    }

    private func load() async {
        @Dependency(\.fetchTeam) var fetchTeam

        if let team = try? await fetchTeam() {
            teamMembers = team
        }
    }
}
