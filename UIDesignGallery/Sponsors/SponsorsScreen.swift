import SwiftUI
import UIDesign

/// A view that lists the companies paying for the conference, by tier.
struct SponsorsScreen: View {
    var body: some View {
        NavigationStack {
            List {
                tier("Headline", sponsors: SampleSponsor.headline)
                tier("Gold", sponsors: SampleSponsor.gold)
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background { AmbientBackground() }
            .navigationTitle("Sponsors")
            .navigationDestination(for: SampleSponsor.self) { sponsor in
                NotYetDesigned(destination: .sponsors)
                    .navigationTitle(sponsor.name)
            }
        }
    }

    /// Returns one tier's heading with its companies grouped under it.
    ///
    /// - Parameters:
    ///   - name: What the conference calls this tier.
    ///   - sponsors: The companies at this tier.
    private func tier(_ name: String, sponsors: [SampleSponsor]) -> some View {
        Section(name) {
            ForEach(sponsors) { sponsor in
                NavigationLink(value: sponsor) {
                    SponsorRow(sponsor: sponsor)
                }
            }
        }
        .listRowBackground(ContentSurface())
    }
}
