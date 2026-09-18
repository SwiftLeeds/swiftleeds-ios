#if canImport(UIKit)
import Dependencies
import LocalFeature
import Observation

extension LocalView {
    @Observable
    @MainActor
    final class ViewModel {
        private(set) var categories: [LocationCategory] = []
        private(set) var error: LocationCategoryFetchError?

        var selectedCategory: LocationCategory?

        var selectedLocations: [Location] {
            selectedCategory?.locations ?? []
        }

        func load() async {
            @Dependency(\.fetchLocationCategories) var fetchLocationCategories

            do {
                categories = try await fetchLocationCategories().filter { !$0.locations.isEmpty }
                selectedCategory = categories.first
                error = nil
            } catch {
                self.error = error
            }
        }
    }
}
#endif
