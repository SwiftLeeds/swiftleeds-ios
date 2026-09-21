import AboutFeature
import Combine
import Dependencies
import Foundation
import NetworkKit

@MainActor
class AboutViewModel: ObservableObject {
    @Published var aboutContent: AboutContent?
    @Published var teamMembers: [TeamMember] = []
    @Published var isLoading = true
    @Published var errorMessage: String?

    var venueURL: URL? {
        aboutContent.flatMap { apiURL(path: $0.urls.venue) }
    }

    var codeOfConductURL: URL? {
        aboutContent.flatMap { apiURL(path: $0.urls.codeOfConduct) }
    }

    var reportAProblemLink: String {
        return aboutContent?.urls.reportAProblem ?? ""
    }

    var slackURL: URL? {
        guard let urlString = aboutContent?.urls.slack else { return nil }
        return URL(string: urlString)
    }

    var youtubeURL: URL? {
        guard let urlString = aboutContent?.urls.youtube else { return nil }
        return URL(string: urlString)
    }

    var truncatedAboutText: String {
        return aboutContent?.truncatedAboutText ?? ""
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

        // Load about content (URLs, text) from local JSON
        loadLocalAboutContent()

        // Load team data from API
        await loadTeamData()

        isLoading = false
    }

    private func loadLocalAboutContent() {
        guard let url = Bundle.module.url(forResource: "about", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            errorMessage = "Could not find about.json file"
            return
        }

        do {
            let decoder = JSONDecoder()
            let loadedContent = try decoder.decode(AboutContent.self, from: data)
            self.aboutContent = loadedContent
        } catch {
            errorMessage = "Error parsing about.json: \(error.localizedDescription)"
        }
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
