import SwiftUI
import Networking
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
            let localResults = try await URLSession.shared.decode(Requests.local, dateDecodingStrategy: Requests.defaultDateDecodingStratergy)
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

private extension Requests {
    static let local = Request<Local>(
        host: host,
        path: "\(apiVersion1)/local",
        eTagKey: "etag-local"
    )
}
