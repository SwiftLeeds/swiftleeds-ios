import SwiftUI
import UIDesign

/// A view that lists the companies paying for the conference, by tier.
struct SponsorsScreen: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: .large) {
                    // The ring is on the top tier only, to show what it looks
                    // like beside a tier that goes without one.
                    tier("Headline", sponsors: SampleSponsor.headline, role: .headlineSponsor)
                    tier("Gold", sponsors: SampleSponsor.gold, role: nil)
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
    ///   - role: The standing a ring marks, or `nil` for no ring.
    private func tier(
        _ name: String,
        sponsors: [SampleSponsor],
        role: ConferenceRole?
    ) -> some View {
        VStack(alignment: .leading, spacing: .small) {
            Text(name)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.textPrimary)

            VStack(spacing: 0) {
                ForEach(Array(sponsors.enumerated()), id: \.element.id) { index, sponsor in
                    NavigationLink(value: sponsor) {
                        SponsorRow(sponsor: sponsor, role: role)
                    }
                    .buttonStyle(.plain)

                    if index < sponsors.count - 1 {
                        Divider().padding(.leading, SponsorRow.separatorInset)
                    }
                }
            }
            .contentGroup()
        }
    }
}
