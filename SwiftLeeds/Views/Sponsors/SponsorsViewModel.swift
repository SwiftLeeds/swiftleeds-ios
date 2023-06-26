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
    @Published var sponsors: [Sponsor] = [Sponsor]()

    func loadSponsors() async throws {
        do {
            let sponsors = try await network.performRequest(endpoint: SponsorsEndpoint())
            await MainActor.run {
                self.sponsors = sponsors.data
            }
        } catch {
            throw(error)
        }
    }
}
