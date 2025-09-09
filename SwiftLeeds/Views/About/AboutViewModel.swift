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
    @Published var aboutData: AboutData?
    @Published var isLoading = true
    @Published var errorMessage: String?
    
    var venueURL: URL? {
        guard let urlString = aboutData?.urls.venue else { return nil }
        return URL(string: urlString)
    }
    
    var codeOfConductURL: URL? {
        guard let urlString = aboutData?.urls.codeOfConduct else { return nil }
        return URL(string: urlString)
    }
    
    var reportAProblemLink: String {
        return aboutData?.urls.reportAProblem ?? ""
    }
    
    var slackURL: URL? {
        guard let urlString = aboutData?.urls.slack else { return nil }
        return URL(string: urlString)
    }
    
    var youtubeURL: URL? {
        guard let urlString = aboutData?.urls.youtube else { return nil }
        return URL(string: urlString)
    }
    
    var truncatedAboutText: String {
        return aboutData?.truncatedAboutText ?? ""
    }
    
    var teamMembers: [TeamMember] {
        return aboutData?.teamMembers ?? []
    }
    
    init() {
        loadAboutData()
    }
    
    private func loadAboutData() {
        isLoading = true
        errorMessage = nil
        
        guard let path = Bundle.main.path(forResource: "about", ofType: "json"),
              let data = NSData(contentsOfFile: path) as Data? else {
            errorMessage = "Could not find about.json file"
            isLoading = false
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let loadedData = try decoder.decode(AboutData.self, from: data)
            self.aboutData = loadedData
            isLoading = false
        } catch {
            errorMessage = "Error parsing about.json: \(error.localizedDescription)"
            isLoading = false
        }
    }
}
