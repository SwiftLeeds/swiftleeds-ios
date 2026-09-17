import Dependencies
import Foundation
import LocalFeature
import SwiftUI

class LocalViewModel: ObservableObject {
    @Published private(set) var categories: [LocationCategory] = []
    @Published private(set) var selectedLocations: [Location] = []

    @Published var selectedCategory: LocationCategory? {
        didSet { selectedLocations = selectedCategory?.locations ?? [] }
    }

    private(set) var error: Error?

    init() {
        Task {
            await loadData()
        }
    }

    func loadData() async {
        @Dependency(\.fetchLocationCategories) var fetchLocationCategories

        do {
            await updateLocal(try await fetchLocationCategories())
        } catch {
            self.error = error
        }
    }

    @MainActor
    private func updateLocal(_ categories: [LocationCategory]) async {
        self.error = nil
        self.categories = categories
        self.selectedCategory = self.categories.first
    }
}
