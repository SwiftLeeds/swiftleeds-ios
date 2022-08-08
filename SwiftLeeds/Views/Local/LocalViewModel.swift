//
//  LocalViewModel.swift
//  SwiftLeeds
//
//  Created by Alex Logan on 08/08/2022.
//

import Foundation
import NetworkKit
import SwiftUI

class LocalViewModel: ObservableObject {
    @Environment(\.network) var network: Networking

    var categories: [Local.LocationCategory] = []
    var error: Error?
    
    func loadData() async {
        do {
            let localResults = try await network.performRequest(endpoint: LocalEndpoint())
            self.categories = localResults.data
        } catch {
            self.error = error
        }
        await publishResults()
    }

    @MainActor
    private func publishResults() {
        self.objectWillChange.send()
    }
}
