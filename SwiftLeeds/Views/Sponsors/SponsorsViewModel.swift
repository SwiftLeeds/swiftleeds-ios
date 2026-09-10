import Combine
import Dependencies
import Foundation
import NetworkKit
import SwiftUI

final class SponsorsViewModel: ObservableObject {
    @Published private(set) var sections: [Section] = [Section]()

    struct Section: Identifiable {
        let type: SponsorLevel
        let sponsors: [Sponsor]
        var id: String { type.rawValue }
    }

    func loadSponsors() async throws {
        @Dependency(\.httpClient) var httpClient
        @Dependency(\.sponsorsMapper) var sponsorsMapper

        let (data, response) = try await httpClient.send(Endpoint.sponsors.urlRequest())
        let sponsors = try sponsorsMapper.map(data, response)
        await updateSponsors(sponsors)
    }

    @MainActor
    private func updateSponsors(_ sponsors: Sponsors) async {
        var sections: [Section] = [Section]()
        let sponsors = sponsors.data

        let platinumSponsors = sponsors
            .filter {$0.sponsorLevel == .platinum}
            .compactMap { $0 }
        if !platinumSponsors.isEmpty {
            sections.append(Section(type: .platinum, sponsors: platinumSponsors))
        }

        let goldSponsors = sponsors
            .filter {$0.sponsorLevel == .gold}
            .compactMap { $0 }
        if !goldSponsors.isEmpty {
            sections.append(Section(type: .gold, sponsors: goldSponsors))
        }

        let silverSponsors = sponsors
            .filter {$0.sponsorLevel == .silver}
            .compactMap { $0 }
        if !silverSponsors.isEmpty {
            sections.append(Section(type: .silver, sponsors: silverSponsors))
        }

        self.sections = sections
    }
}
