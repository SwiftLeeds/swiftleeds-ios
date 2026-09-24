import SwiftUI
import UIDesign

/// An app that shows the redesigned screens with the system's own chrome.
///
/// Every screen is built from the containers iOS draws itself, so the tab bar,
/// the navigation bar and the toolbar are real rather than approximations.
///
/// A session cannot tap the simulator, so the screen to open arrives as a
/// launch argument. `-tab sponsors` chooses a destination, and `-detail 1`
/// pushes a session's detail onto the schedule.
@main
struct UIDesignGalleryApp: App {
    /// The destination named by the `-tab` launch argument.
    ///
    /// An absent or unrecognized name opens the schedule.
    private var tab: GalleryTab {
        let name = UserDefaults.standard.string(forKey: "tab") ?? ""
        return GalleryTab(rawValue: name) ?? .schedule
    }

    /// Whether the schedule opens with a session's detail already pushed.
    private var showsSessionDetail: Bool {
        UserDefaults.standard.bool(forKey: "detail")
    }

    var body: some Scene {
        WindowGroup {
            TabView(selection: .constant(tab)) {
                Tab(
                    GalleryTab.schedule.title,
                    systemImage: GalleryTab.schedule.symbol,
                    value: GalleryTab.schedule
                ) {
                    ScheduleScreen(showsSessionDetail: showsSessionDetail)
                }

                Tab(
                    GalleryTab.venue.title,
                    systemImage: GalleryTab.venue.symbol,
                    value: GalleryTab.venue
                ) {
                    NotYetDesigned(destination: .venue)
                }

                Tab(
                    GalleryTab.sponsors.title,
                    systemImage: GalleryTab.sponsors.symbol,
                    value: GalleryTab.sponsors
                ) {
                    SponsorsScreen()
                }

                Tab(value: GalleryTab.search, role: .search) {
                    NotYetDesigned(destination: .search)
                }
            }
            .tint(.brandPrimary)
        }
    }
}
