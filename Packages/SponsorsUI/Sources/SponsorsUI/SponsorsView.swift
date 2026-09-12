import Dependencies
import SponsorsFeature
import SwiftUI

/// The sponsors screen. Fetches the sponsors, then hands them to the view that draws them.
public struct SponsorsView: View {
    @State private var viewModel = ViewModel()
    @State private var state = SponsorsContentView.ScreenState.loading

    public init() {}

    public var body: some View {
        SponsorsContentView(state: state)
            .task {
                await loadSponsors()
            }
    }

    private func loadSponsors() async {
        try? await viewModel.loadSponsors()
        withAnimation(.easeInOut(duration: 0.3)) {
            state = .init(viewModel.sponsors)
        }
    }
}

extension SponsorsView {
    @Observable
    @MainActor
    final class ViewModel {
        private(set) var sponsors = Sponsors([])

        func loadSponsors() async throws(SponsorFetchError) {
            @Dependency(\.fetchSponsors) var fetchSponsors

            sponsors = try await fetchSponsors()
        }
    }
}

struct SponsorsView_Previews: PreviewProvider {
    static var previews: some View {
        SponsorsView()
    }
}
