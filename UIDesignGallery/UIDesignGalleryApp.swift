import SwiftUI
import UIDesign

/// An app that shows the redesigned screens with the system's own chrome.
///
/// Every screen is built from the containers iOS draws itself, so the tab bar,
/// the navigation bar and the toolbar are real rather than approximations.
///
/// A launch argument picks where the app opens, so a screenshot needs no
/// tapping. `-tab sponsors` chooses a destination, `-detail 1` pushes a
/// session's detail, and `-rows card` swaps the schedule's arrangement.
@main
struct UIDesignGalleryApp: App {
    /// The destination on screen.
    ///
    /// The launch argument chooses where the app opens. It is state rather
    /// than a constant so the tab bar still works once it is open.
    @State private var tab: GalleryTab

    /// Whether the schedule opens with a session's detail already pushed.
    private let showsSessionDetail: Bool

    /// How the schedule separates one session from the next.
    private let rowStyle: ScheduleScreen.RowStyle

    /// Creates the app, reading where to open from the launch arguments.
    init() {
        let defaults = UserDefaults.standard
        let name = defaults.string(forKey: "tab") ?? ""
        _tab = State(initialValue: GalleryTab(rawValue: name) ?? .schedule)
        showsSessionDetail = defaults.bool(forKey: "detail")
        let rows = defaults.string(forKey: "rows") ?? ""
        rowStyle = ScheduleScreen.RowStyle(rawValue: rows) ?? .bare
    }

    var body: some Scene {
        WindowGroup {
            TabView(selection: $tab) {
                Tab(
                    GalleryTab.schedule.title,
                    systemImage: GalleryTab.schedule.symbol,
                    value: GalleryTab.schedule
                ) {
                    ScheduleScreen(showsSessionDetail: showsSessionDetail, rowStyle: rowStyle)
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
