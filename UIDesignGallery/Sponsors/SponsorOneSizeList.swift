import SwiftUI
import UIDesign

/// A list that shows every sponsor in a row of one size, grouped by tier.
///
/// Each row pushes the sponsor's page, so the list belongs in a navigation stack.
struct SponsorOneSizeList: View {
    var body: some View {
        List {
            ForEach(SampleSponsorTier.allCases) { tier in
                Section(tier.title) {
                    ForEach(SampleSponsor.sponsors(in: tier)) { sponsor in
                        NavigationLink(value: sponsor) {
                            SponsorRow(sponsor: sponsor)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}
