import Combine
import Dependencies
import SponsorsFeature

@MainActor
final class SponsorsViewModel: ObservableObject {
    @Published private(set) var sponsors = Sponsors([])

    func loadSponsors() async throws(SponsorFetchError) {
        @Dependency(\.fetchSponsors) var fetchSponsors

        sponsors = try await fetchSponsors()
    }
}
