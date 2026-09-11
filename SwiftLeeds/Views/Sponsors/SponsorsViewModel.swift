import Combine
import Dependencies
import SponsorsFeature

final class SponsorsViewModel: ObservableObject {
    @Published private(set) var sponsors = Sponsors([])

    func loadSponsors() async throws(SponsorFetchError) {
        @Dependency(\.fetchSponsors) var fetchSponsors

        let sponsors = try await fetchSponsors()
        await updateSponsors(sponsors)
    }

    @MainActor
    private func updateSponsors(_ sponsors: Sponsors) {
        self.sponsors = sponsors
    }
}
