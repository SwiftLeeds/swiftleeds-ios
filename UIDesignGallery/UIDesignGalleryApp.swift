import SwiftUI
import UIDesign

/// An app that shows the redesigned screens with the system's own chrome.
///
/// Every screen is built from the containers iOS draws itself, so the tab bar,
/// the navigation bar and the toolbar are real rather than approximations.
///
/// A launch argument picks where the app opens, so a screenshot needs no
/// tapping. `-tab sponsors` chooses a destination, `-detail 1` pushes a
/// session's detail, `-profile 1` pushes the signed-in person's profile,
/// `-rows card` swaps the schedule's arrangement, `-halo hard` or `-halo soft`
/// swaps the halo's outer edge for the one it feathers between, and
/// `-halos 1` shows every halo treatment at once instead of the app.
@main
struct UIDesignGalleryApp: App {
    /// The destination on screen.
    ///
    /// The launch argument chooses where the app opens. It is state rather
    /// than a constant so the tab bar still works once it is open.
    @State private var tab: GalleryTab

    /// The screen the schedule opens with already pushed, if any.
    private let opensWith: ScheduleDestination?

    /// How the schedule separates one session from the next.
    private let rowStyle: ScheduleScreen.RowStyle

    /// How the halo's outer edge meets the screen behind it.
    private let haloEdge: HaloEdge

    /// Whether the gallery shows the halo treatments instead of the app.
    private let comparesHalos: Bool

    /// Creates the app, reading where to open from the launch arguments.
    init() {
        let defaults = UserDefaults.standard
        let name = defaults.string(forKey: "tab") ?? ""
        _tab = State(initialValue: GalleryTab(rawValue: name) ?? .schedule)
        if defaults.bool(forKey: "profile") {
            opensWith = .profile
        } else if defaults.bool(forKey: "detail") {
            opensWith = .session(.opening)
        } else {
            opensWith = nil
        }
        let rows = defaults.string(forKey: "rows") ?? ""
        rowStyle = ScheduleScreen.RowStyle(rawValue: rows) ?? .bare
        let halo = defaults.string(forKey: "halo") ?? ""
        haloEdge = HaloEdge(rawValue: halo) ?? .feathered
        comparesHalos = defaults.bool(forKey: "halos")
    }

    var body: some Scene {
        WindowGroup {
            if comparesHalos {
                HaloComparison()
            } else {
                app
            }
        }
    }

    /// The gallery's own screens, under the system's tab bar.
    private var app: some View {
        TabView(selection: $tab) {
            Tab(
                GalleryTab.schedule.title,
                systemImage: GalleryTab.schedule.symbol,
                value: GalleryTab.schedule
            ) {
                ScheduleScreen(opensWith: opensWith, rowStyle: rowStyle, haloEdge: haloEdge)
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
