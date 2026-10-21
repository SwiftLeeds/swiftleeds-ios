import SwiftUI
import UIDesign

/// A view that lists the companies paying for the conference, by tier.
struct SponsorsScreen: View {
    var body: some View {
        NavigationStack {
            SponsorOneSizeList()
                .navigationTitle("Sponsors")
                .navigationDestination(for: SampleSponsor.self) { sponsor in
                    NotYetDesigned(destination: .sponsors)
                        .navigationTitle(sponsor.name)
                }
        }
    }
}
