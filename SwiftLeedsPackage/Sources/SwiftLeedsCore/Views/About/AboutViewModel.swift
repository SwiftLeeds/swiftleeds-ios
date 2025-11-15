//
//  AboutViewModel.swift
//  SwiftLeeds
//
//  Created by Muralidharan Kathiresan on 09/09/2025.
//

import Foundation
import Combine

// MARK: - ViewModel
@MainActor
class AboutViewModel: ObservableObject {
    @Published var aboutContent: AboutContent?
    @Published var teamMembers: [TeamMember] = []
    @Published var isLoading = true
    @Published var errorMessage: String?
    
    var venueURL: URL? {
        guard let urlString = aboutContent?.urls.venue else { return nil }
        return URL(string: urlString)
    }
    
    var codeOfConductURL: URL? {
        guard let urlString = aboutContent?.urls.codeOfConduct else { return nil }
        return URL(string: urlString)
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
        do {
            let teamApiResponse = try await URLSession.shared.decode(
                Requests.team, 
                dateDecodingStrategy: Requests.defaultDateDecodingStratergy
            )
            await updateTeamMembers(teamApiResponse.teamMembers)
        } catch {
            // Try to load from cache if API fails
            if let cachedResponse = try? await URLSession.shared.cached(
                Requests.team, 
                dateDecodingStrategy: Requests.defaultDateDecodingStratergy
            ) {
                await updateTeamMembers(cachedResponse.teamMembers)
            } else {
                errorMessage = "Failed to load team data: \(error.localizedDescription)"
            }
        }
    }
    
    @MainActor
    private func updateTeamMembers(_ members: [TeamMember]) async {
        self.teamMembers = members
    }
}
