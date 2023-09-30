//
//  LocalViewModel.swift
//  SwiftLeeds
//
//  Created by Alex Logan on 08/08/2022.
//

import SwiftUI
import MapKit

class LocalViewModel: ObservableObject {
    @Published private(set) var categories: [Local.LocationCategory] = []
    @Published private(set) var selectedLocations: [Local.Location] = []

    @Published var selectedCategory: Local.LocationCategory? {
        didSet { selectedLocations = selectedCategory?.locations ?? [] }
    }

    private(set) var error: Error?

    init() {
        Task {
            await loadData()
        }
    }
    
    func loadData() async {
        do {
            let localResults = try await URLSession.awaitConnectivity.decode(Requests.local, dateDecodingStrategy: Requests.defaultDateDecodingStratergy)
            await updateLocal(localResults)
        } catch {
            if let cachedResponse = try? await URLSession.shared.cached(Requests.local, dateDecodingStrategy: Requests.defaultDateDecodingStratergy) {
                await updateLocal(cachedResponse)
            } else {
                self.error = error
            }
        }
    }

    @MainActor
    private func updateLocal(_ localResults: Local) async {
        self.categories = localResults.data
        self.selectedCategory = self.categories.first
    }
}
