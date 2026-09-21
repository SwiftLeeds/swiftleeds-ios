import AboutFeature
import Combine
import Dependencies
import Foundation
import NetworkKit

@MainActor
class AboutViewModel: ObservableObject {
    @Published var teamMembers: [TeamMember] = []
    @Published var isLoading = true
    @Published var errorMessage: String?

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

    init() {
        Task {
            await loadData()
        }
    }

    private func apiURL(path: String) -> URL? {
        @Dependency(\.apiConfiguration) var apiConfiguration
        return URL(string: path, relativeTo: apiConfiguration.baseURL)?.absoluteURL
    }

    private func loadData() async {
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
