//
//  SponsorsViewModel.swift
//  SwiftLeeds
//
//  Created by Muralidharan Kathiresan on 25/06/23.
//

import Foundation
import Combine
import NetworkKit
import SwiftUI

final class SponsorsViewModel: ObservableObject {
    @Environment(\.network) var network: Networking
    @Published var sections: [Section] = [Section]()

    struct Section: Identifiable {
        let type: SponsorLevel
        let sponsors: [Sponsor]
        var id : String { type.rawValue }
    }

    func loadSponsors() async throws {
        do {
            let sponsors = try await network.performRequest(endpoint: SponsorsEndpoint())
            await MainActor.run {
                var sections: [Section] = [Section]()
                let sponsors = sponsors.data
                let silverSponsors = sponsors
                    .filter {$0.sponsorLevel == .silver}
                    .compactMap { $0 }
                let goldSponsors = sponsors
                    .filter {$0.sponsorLevel == .gold}
                    .compactMap { $0 }
                let platinumSponsors = sponsors
                    .filter {$0.sponsorLevel == .platinum}
                    .compactMap { $0 }
                sections.append(Section(type: .silver, sponsors: silverSponsors))
                sections.append(Section(type: .gold, sponsors: goldSponsors))
                sections.append(Section(type: .platinum, sponsors: platinumSponsors))
                self.sections = sections
            }
        } catch {
            throw(error)
        }
    }
}
