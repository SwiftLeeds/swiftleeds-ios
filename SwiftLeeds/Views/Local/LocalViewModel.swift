//
//  LocalViewModel.swift
//  SwiftLeeds
//
//  Created by Alex Logan on 08/08/2022.
//

import NetworkKit
import SwiftUI
import MapKit

class LocalViewModel: ObservableObject {
    @Published var selectedCategory: Local.LocationCategory? {
        didSet { selectedLocations = selectedCategory?.locations ?? [] }
    }

    @Published var categories: [Local.LocationCategory] = []
    @Published var selectedLocations: [Local.Location] = []

    @Environment(\.network) var network: Networking

    var error: Error?

    init() {
        Task {
            await loadData()
        }
    }
    
    func loadData() async {
        do {
            let localResults = try await network.performRequest(endpoint: LocalEndpoint())

            DispatchQueue.main.async {
                self.categories = localResults.data
                self.selectedCategory = self.categories.first
            }
        } catch {
            self.error = error
        }
    }
}
