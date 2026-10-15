import SwiftUI

/// The Venue tab, which gives the venue content a navigation stack of its own.
struct VenueScreen: View {
    var body: some View {
        NavigationStack {
            VenueContent()
        }
    }
}
