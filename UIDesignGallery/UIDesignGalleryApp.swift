import SwiftUI
import UIDesign

/// An app that shows the redesigned screens with the system's own chrome.
///
/// Every screen is built from the containers iOS draws itself, so the tab bar,
/// the navigation bar and the toolbar are real rather than approximations.
///
/// A launch argument picks where the app opens, so a screenshot needs no
/// tapping. `-tab sponsors` chooses a destination, `-detail 1` pushes a
/// session's detail, `-settings 1` presents Settings, `-profile 1` presents
/// Settings with the signed-in person's profile pushed on top of it,
/// `-category about` presents Settings with that part of it pushed on top,
/// `-signin blank` or `-signin filled` presents Sign in with its fields
/// empty or filled in, `-halo hard` or `-halo soft` swaps the halo's outer
/// edge for the one it feathers between, `-ticket attendee`, `-ticket speaker`,
/// `-ticket sponsor`, `-ticket staff` or `-ticket unavailable` presents that
/// ticket, `-band patterned` draws each role's texture on the ticket's band,
/// and `-halos role`, `-halos pink` or `-halos gold` shows every halo
/// treatment at once, in those colors, instead of the app.
@main
struct UIDesignGalleryApp: App {
    /// The destination on screen.
    ///
    /// The launch argument chooses where the app opens. It is state rather
    /// than a constant so the tab bar still works once it is open.
    @State private var tab: GalleryTab

    /// The screen the schedule opens with already pushed, if any.
    private let opensWith: ScheduleDestination?

    /// How the halo's outer edge meets the screen behind it.
    private let haloEdge: HaloEdge

    /// Whether the role band on a ticket draws the role's texture.
    private let bandVariant: BandVariant

    /// The standing whose colors the halo treatments draw, or `nil` when the
    /// gallery shows the app instead of the treatments.
    private let comparedHalo: ConferenceRole?

    /// Creates the app, reading where to open from the launch arguments.
    init() {
        let defaults = UserDefaults.standard
        let name = defaults.string(forKey: "tab") ?? ""
        _tab = State(initialValue: GalleryTab(rawValue: name) ?? .schedule)
        let category = defaults.string(forKey: "category") ?? ""
        if let ticket = SampleTicket.named(defaults.string(forKey: "ticket") ?? "") {
            opensWith = .ticket(ticket)
        } else if let category = SettingsCategory(rawValue: category) {
            opensWith = .settingsCategory(category)
        } else if let state = SignInState(rawValue: defaults.string(forKey: "signin") ?? "") {
            opensWith = .signIn(state)
        } else if defaults.bool(forKey: "profile") {
            opensWith = .profile
        } else if defaults.bool(forKey: "settings") {
            opensWith = .settings
        } else if defaults.bool(forKey: "detail") {
            opensWith = .session(.opening)
        } else {
            opensWith = nil
        }
        let halo = defaults.string(forKey: "halo") ?? ""
        haloEdge = HaloEdge(rawValue: halo) ?? .feathered
        bandVariant = BandVariant(rawValue: defaults.string(forKey: "band") ?? "") ?? .plain
        switch defaults.string(forKey: "halos") {
        case "pink":
            comparedHalo = HaloComparison.brandPink
        case "gold":
            comparedHalo = HaloComparison.brandGold
        case .some:
            comparedHalo = SampleAttendee.signedIn.role
        case .none:
            comparedHalo = nil
        }
    }

    var body: some Scene {
        WindowGroup {
            if let comparedHalo {
                HaloComparison(role: comparedHalo)
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
                value: GalleryTab.schedule,
            ) {
                ScheduleScreen(opensWith: opensWith, haloEdge: haloEdge, bandVariant: bandVariant)
            }

            Tab(
                GalleryTab.venue.title,
                systemImage: GalleryTab.venue.symbol,
                value: GalleryTab.venue,
            ) {
                VenueScreen()
            }

            Tab(
                GalleryTab.sponsors.title,
                systemImage: GalleryTab.sponsors.symbol,
                value: GalleryTab.sponsors,
            ) {
                SponsorsScreen()
            }

            Tab(value: GalleryTab.search, role: .search) {
                SearchScreen()
            }
        }
        .tint(.brandPrimary)
    }
}
