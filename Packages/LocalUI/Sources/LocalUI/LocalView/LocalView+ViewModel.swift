#if canImport(UIKit)
import Dependencies
import LocalFeature
import Observation

extension LocalView {
    @Observable
    @MainActor
    final class ViewModel {
        private(set) var state = LocalContentView.ScreenState.loading

        func loadIfNeeded() async {
            if case .loaded = state { return }
            await load()
        }

        func load() async {
            @Dependency(\.fetchLocationCategories) var fetchLocationCategories

            do {
                state = .loaded(try await fetchLocationCategories().filter { !$0.locations.isEmpty })
            } catch {
                guard !Task.isCancelled else { return }
                state = .failed
            }
        }
    }
}
#endif
