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
/// `-person dana`, `-person blake`, `-person casey`, `-person eli`,
/// `-person fay` or `-person gus` pushes that person's page, `-favorite 1` opens
/// a person page or a session detail already a favourite, `-moment before`,
/// `-moment during` or `-moment after` sets where in its day a session detail
/// pretends to be, `-bio expanded` opens it with the
/// bio in full, `-summary expanded` opens a session detail with the sheet
/// of its full summary showing, `-detail accessibility` pushes the two-speaker workshop's
/// detail, `-detail dropin` pushes the drop-in session's detail, `-sidebar 1`
/// shows the tabs as a sidebar on a regular width, and `-halos role`,
/// `-halos pink` or `-halos gold` shows every halo treatment at once, in those
/// colors, instead of the app.
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

    /// Whether a person page or a session detail opens already a favourite.
    private let opensFavorite: Bool

    /// Whether the person page opens with the bio in full.
    private let opensBioExpanded: Bool

    /// Whether a session detail opens with the sheet of its full summary showing.
    private let opensSummaryExpanded: Bool

    /// Whether the tab bar adapts into a sidebar on a regular width.
    private let usesSidebar: Bool

    /// The standing whose colors the halo treatments draw, or `nil` when the
    /// gallery shows the app instead of the treatments.
    private let comparedHalo: ConferenceRole?

    /// Creates the app, reading where to open from the launch arguments.
    init() {
        let defaults = UserDefaults.standard
        let name = defaults.string(forKey: "tab") ?? ""
        _tab = State(initialValue: GalleryTab(rawValue: name) ?? .schedule)
        opensWith = Self.destination(from: defaults)
        let halo = defaults.string(forKey: "halo") ?? ""
        haloEdge = HaloEdge(rawValue: halo) ?? .feathered
        bandVariant = BandVariant(rawValue: defaults.string(forKey: "band") ?? "") ?? .plain
        opensFavorite = defaults.bool(forKey: "favorite")
        opensBioExpanded = defaults.string(forKey: "bio") == "expanded"
        opensSummaryExpanded = defaults.string(forKey: "summary") == "expanded"
        usesSidebar = defaults.bool(forKey: "sidebar")
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

    /// Returns the screen the launch arguments ask the schedule to open with,
    /// or `nil` when they name none.
    ///
    /// The first argument found wins, in the order the app's doc comment lists
    /// them.
    ///
    /// - Parameter defaults: Where the launch arguments were read into.
    private static func destination(from defaults: UserDefaults) -> ScheduleDestination? {
        let category = defaults.string(forKey: "category") ?? ""
        if let ticket = SampleTicket.named(defaults.string(forKey: "ticket") ?? "") {
            return .ticket(ticket)
        } else if let person = SamplePerson.named(defaults.string(forKey: "person") ?? "") {
            return .person(person)
        } else if let category = SettingsCategory(rawValue: category) {
            return .settingsCategory(category)
        } else if let state = SignInState(rawValue: defaults.string(forKey: "signin") ?? "") {
            return .signIn(state)
        } else if defaults.bool(forKey: "profile") {
            return .profile
        } else if defaults.bool(forKey: "settings") {
            return .settings
        } else if defaults.string(forKey: "detail") == "accessibility" {
            return .session(.accessibility)
        } else if defaults.string(forKey: "detail") == "dropin" {
            return .session(.dropIn)
        } else if defaults.bool(forKey: "detail") {
            return .session(.opening)
        } else {
            return nil
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

    /// The gallery's own screens, in a sidebar when the launch argument asks.
    @ViewBuilder
    private var app: some View {
        if usesSidebar {
            tabs
                .tabViewStyle(.sidebarAdaptable)
                .defaultAdaptableTabBarPlacement(.sidebar)
        } else {
            tabs
        }
    }

    /// The gallery's own screens, under the system's tab bar.
    private var tabs: some View {
        TabView(selection: $tab) {
            Tab(
                GalleryTab.schedule.title,
                systemImage: GalleryTab.schedule.symbol,
                value: GalleryTab.schedule,
            ) {
                ScheduleScreen(
                    opensWith: opensWith,
                    haloEdge: haloEdge,
                    bandVariant: bandVariant,
                    opensFavorite: opensFavorite,
                    opensBioExpanded: opensBioExpanded,
                    opensSummaryExpanded: opensSummaryExpanded,
                )
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
