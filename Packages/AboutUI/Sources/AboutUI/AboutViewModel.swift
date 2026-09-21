import AboutFeature
import Dependencies
import Foundation
import NetworkKit
import Observation

@Observable
@MainActor
final class AboutViewModel {
    private(set) var teamMembers: [TeamMember] = []
    private(set) var isLoading = true
    private(set) var errorMessage: String?

    private let aboutContent = AboutContent.swiftLeeds

    var venueURL: URL? {
        apiURL(path: aboutContent.urls.venue)
    }

    var codeOfConductURL: URL? {
        apiURL(path: aboutContent.urls.codeOfConduct)
    }

    var reportAProblemLink: String {
        aboutContent.urls.reportAProblem
    }

    var slackURL: URL? {
        URL(string: aboutContent.urls.slack)
    }

    var youtubeURL: URL? {
        URL(string: aboutContent.urls.youtube)
    }

    var truncatedAboutText: String {
        aboutContent.truncatedAboutText
    }

    func loadIfNeeded() async {
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
            errorMessage = "Failed to load team data: \(error.localizedDescription)"
        }
    }
}
