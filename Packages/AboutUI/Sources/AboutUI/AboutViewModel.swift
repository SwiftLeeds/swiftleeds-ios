import AboutFeature
import Dependencies
import Foundation
import NetworkKit
import Observation

/// The About screen's state: its links and text, and the conference team.
@Observable
@MainActor
package final class AboutViewModel {
    package private(set) var teamMembers: [TeamMember] = []
    private(set) var isLoading = true
    package private(set) var errorMessage: String?

    private let aboutContent = AboutContent.swiftLeeds

    /// Creates the state with no team loaded.
    package init() {}

    /// The venue page on the conference site.
    package var venueURL: URL? {
        apiURL(path: aboutContent.links.venue)
    }

    /// The code of conduct page on the conference site.
    package var codeOfConductURL: URL? {
        apiURL(path: aboutContent.links.codeOfConduct)
    }

    /// The form for reporting a problem.
    package var reportAProblemLink: String {
        aboutContent.links.reportAProblem
    }

    /// The invite to the conference Slack.
    package var slackURL: URL? {
        URL(string: aboutContent.links.slack)
    }

    /// The conference YouTube channel.
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
        isLoading = true
        errorMessage = nil
        await loadTeamData()
        isLoading = false
    }

    private func loadTeamData() async {
        @Dependency(\.fetchTeam) var fetchTeam

        do {
            teamMembers = try await fetchTeam()
        } catch {
            guard !Task.isCancelled else { return }
            errorMessage = "Failed to load team data: \(error.localizedDescription)"
        }
    }
}
