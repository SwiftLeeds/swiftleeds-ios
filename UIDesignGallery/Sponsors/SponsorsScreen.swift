import SwiftUI
import UIDesign

/// A view that lists the companies paying for the conference, by tier.
struct SponsorsScreen: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Headline") {
                    ForEach(SampleSponsor.headline) { sponsor in
                        NavigationLink(value: sponsor) {
                            SponsorRow(sponsor: sponsor)
                        }
                    }
                }

                Section("Gold") {
                    ForEach(SampleSponsor.gold) { sponsor in
                        NavigationLink(value: sponsor) {
                            SponsorRow(sponsor: sponsor)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Sponsors")
            .navigationDestination(for: SampleSponsor.self) { sponsor in
                NotYetDesigned(destination: .sponsors)
                    .navigationTitle(sponsor.name)
            }
        }
    }
}
