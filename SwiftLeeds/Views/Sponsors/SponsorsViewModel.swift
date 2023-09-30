//
//  SponsorsViewModel.swift
//  SwiftLeeds
//
//  Created by Muralidharan Kathiresan on 25/06/23.
//

import Foundation
import Combine
import SwiftUI

final class SponsorsViewModel: ObservableObject {
    @Published private(set) var sections: [Section] = [Section]()

    struct Section: Identifiable {
        let type: SponsorLevel
        let sponsors: [Sponsor]
        var id : String { type.rawValue }
    }

    func loadSponsors() async throws {
        do {
            let sponsors = try await URLSession.awaitConnectivity.decode(Requests.sponsors, dateDecodingStrategy: Requests.defaultDateDecodingStratergy)
            await updateSponsors(sponsors)
        } catch {
            if let cachedResponse = try? await URLSession.shared.cached(Requests.sponsors, dateDecodingStrategy: Requests.defaultDateDecodingStratergy) {
                await updateSponsors(cachedResponse)
            } else {
                throw(error)
            }
        }
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
