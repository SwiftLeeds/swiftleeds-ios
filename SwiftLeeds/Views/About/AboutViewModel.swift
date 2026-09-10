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
        guard let path = aboutContent?.urls.venue else { return nil }
        return URL(string: "https://\(ConferenceConfig.apiHost)\(path)")
    }

    var codeOfConductURL: URL? {
        guard let path = aboutContent?.urls.codeOfConduct else { return nil }
        return URL(string: "https://\(ConferenceConfig.apiHost)\(path)")
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
        guard let path = Bundle.main.path(forResource: "about", ofType: "json"),
              let data = NSData(contentsOfFile: path) as Data? else {
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
        @Dependency(\.httpClient) var httpClient
        @Dependency(\.teamMapper) var teamMapper

        do {
            let (data, response) = try await httpClient.send(Endpoint.team.urlRequest())
            let team = try teamMapper.map(data, response)
            await updateTeamMembers(team.teamMembers)
        } catch {
            errorMessage = "Failed to load team data: \(error.localizedDescription)"
        }
    }

    @MainActor
    private func updateTeamMembers(_ members: [TeamMember]) async {
        self.teamMembers = members
    }
}
