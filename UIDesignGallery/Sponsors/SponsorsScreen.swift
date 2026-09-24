import SwiftUI
import UIDesign

/// A view that lists the companies paying for the conference, by tier.
struct SponsorsScreen: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: .large) {
                    tier("Headline", sponsors: SampleSponsor.headline)
                    tier("Gold", sponsors: SampleSponsor.gold)
                }
                .padding(.horizontal, .large)
                .padding(.bottom, .large)
            }
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
        VStack(alignment: .leading, spacing: .small) {
            Text(name)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.textPrimary)

            VStack(spacing: 0) {
                ForEach(Array(sponsors.enumerated()), id: \.element.id) { index, sponsor in
                    NavigationLink(value: sponsor) {
                        SponsorRow(sponsor: sponsor)
                    }
                    .buttonStyle(.plain)

                    if index < sponsors.count - 1 {
                        Divider()
                    }
                }
            }
            .contentGroup()
        }
    }
}
