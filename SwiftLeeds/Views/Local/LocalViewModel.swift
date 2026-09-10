import Dependencies
import Foundation
import MapKit
import NetworkKit
import SwiftUI

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
        @Dependency(\.httpClient) var httpClient
        @Dependency(\.localMapper) var localMapper

        do {
            let (data, response) = try await httpClient.send(Endpoint.local.urlRequest())
            let localResults = try localMapper.map(data, response)
            await updateLocal(localResults)
        } catch {
            self.error = error
        }
    }

    @MainActor
    private func updateLocal(_ localResults: Local) async {
        self.error = nil
        self.categories = localResults.data
        self.selectedCategory = self.categories.first
    }
}
