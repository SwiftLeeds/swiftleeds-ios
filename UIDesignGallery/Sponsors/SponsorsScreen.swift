import SwiftUI
import UIDesign

/// A view that lists the companies paying for the conference, by tier.
struct SponsorsScreen: View {
    /// The sponsor pages pushed on top of the list.
    @State private var path: [SampleSponsor]

    /// Creates a screen that lists the sponsors.
    ///
    /// - Parameter opensWith: The sponsor whose page is already pushed when the
    ///   screen appears, or `nil` if you want the list.
    init(opensWith: SampleSponsor? = nil) {
        _path = State(initialValue: opensWith.map { [$0] } ?? [])
    }

    var body: some View {
        NavigationStack(path: $path) {
            SponsorOneSizeList()
                .navigationTitle("Sponsors")
                .navigationDestination(for: SampleSponsor.self) { sponsor in
                    SponsorScreen(sponsor: sponsor)
                }
        }
    }
}
