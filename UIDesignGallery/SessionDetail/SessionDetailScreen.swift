import SwiftUI
import UIDesign

/// A view that describes one session and what a person can do about it.
struct SessionDetailScreen: View {
    /// The height of the clear space that follows the content with `-tall 1`.
    private static let tailHeight: CGFloat = 800

    /// The most lines the summary takes until a person asks for the rest.
    private static let collapsedSummaryLines = 4

    /// The widest the About text grows, so its lines stay readable on an iPad.
    private static let readableWidth: CGFloat = 672

    /// How far content sits in from the safe area on an iPhone, which is
    /// Apple's list margin.
    private static let phoneMargin: CGFloat = 16

    /// How far content sits in from the safe area on an iPad, which is
    /// Apple's list margin.
    private static let padMargin: CGFloat = 20

    /// The session this screen describes.
    let session: SampleSession

    /// The action that shows a person's page.
    let showPerson: (SamplePerson) -> Void

    /// Whether the sheet with the full summary shows when the screen appears.
    private let opensSummaryExpanded: Bool

    /// Whether clear space follows the content, so the title can scroll fully
    /// under the bar. The launch argument `-tall 1` turns it on.
    private let addsTail: Bool

    /// Where in the session's day the screen pretends to be. The launch argument `-moment` picks it.
    private let moment: SessionMoment

    /// How big the page is, or `nil` until it is measured.
    @State private var page: SessionHero.PageSize?

    /// Whether this person favourited the session.
    @State private var isFavorite: Bool

    /// Whether the venue page is pushed, to find the session's room.
    @State private var showsVenue = false

    /// Whether this person has asked to reduce motion.
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// How far the bars cover the list, or `nil` until it first reports.
    @State private var bars: SessionHero.BarInsets?

    /// Creates a screen for one session.
    ///
    /// The launch argument `-moment` picks the moment the screen pretends it is, and `-tall` adds
    /// clear space after the content.
    ///
    /// - Parameters:
    ///   - session: The session this screen describes.
    ///   - opensSummaryExpanded: Whether the sheet with the full summary shows when the
    ///     screen appears.
    ///   - opensFavorite: Whether the session is a favorite when the screen appears, even if the
    ///     sample says it is not.
    ///   - showPerson: The action that shows a person's page.
    init(
        session: SampleSession,
        opensSummaryExpanded: Bool = false,
        opensFavorite: Bool = false,
        showPerson: @escaping (SamplePerson) -> Void,
    ) {
        let defaults = UserDefaults.standard
        self.session = session
        self.opensSummaryExpanded = opensSummaryExpanded
        self.showPerson = showPerson
        moment = SessionMoment(rawValue: defaults.string(forKey: "moment") ?? "") ?? .before
        addsTail = defaults.bool(forKey: "tall")
        _isFavorite = State(initialValue: opensFavorite || session.isFavorite)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                content

                if addsTail {
                    Color.clear.frame(height: Self.tailHeight)
                }
            }
        }
        .onGeometryChange(for: SessionHero.PageSize.self) { proxy in
            SessionHero.PageSize(
                width: proxy.size.width,
                height: proxy.size.height + proxy.safeAreaInsets.top + proxy.safeAreaInsets.bottom,
            )
        } action: { size in
            page = size
        }
        .background(.surface)
        .scrollEdgeEffectStyle(.soft, for: .top)
        .onScrollGeometryChange(for: SessionHero.BarInsets.self) { geometry in
            SessionHero.BarInsets(top: geometry.contentInsets.top, bottom: geometry.contentInsets.bottom)
        } action: { _, newValue in
            bars = newValue
        }
        .navigationDestination(isPresented: $showsVenue) {
            VenueContent()
        }
        .navigationTitle(session.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(removing: .title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                shareButton
            }

            ToolbarSpacer(.fixed, placement: .topBarTrailing)

            ToolbarItem(placement: .topBarTrailing) {
                moreMenu
            }
        }
    }
}

// MARK: - Layout

extension SessionDetailScreen {
    /// The page's content, from the top of the page to its foot.
    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            SessionHero(
                session: session,
                page: page,
                bars: bars,
                margin: margin,
                moment: moment,
                showPerson: showPerson,
                isFavorite: $isFavorite,
            )

            below
        }
    }

    /// The margin on each side of the page, from the safe area to the content.
    private var margin: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? Self.padMargin : Self.phoneMargin
    }

    /// The About text, then the people it credits, at the page margin.
    private var below: some View {
        VStack(alignment: .leading, spacing: .xLarge) {
            aboutCard
                .frame(maxWidth: Self.readableWidth, alignment: .leading)

            CreditedRows(lineup: session.lineup, showPerson: showPerson)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, margin)
        .padding(.top, .large)
        .padding(.bottom, .large)
    }
}

// MARK: - About

extension SessionDetailScreen {
    /// The summary on a rounded surface, under its heading.
    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: .small) {
            Text("About")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            VStack(alignment: .leading, spacing: .medium) {
                CutAboutText(
                    session.summary,
                    lines: Self.collapsedSummaryLines,
                    opensFull: opensSummaryExpanded,
                )
            }
            .padding(.large)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                .secondarySurface,
                in: RoundedRectangle(
                    cornerRadius: CGFloat(CornerRadius.large),
                    style: .continuous,
                ),
            )
        }
    }
}

// MARK: - Toolbar

extension SessionDetailScreen {
    /// The label of the favorite item, which names what it does now.
    private var favoriteLabel: LocalizedStringKey {
        isFavorite ? "Remove from Favourites" : "Add to Favourites"
    }

    /// The menu item that favorites the session, or takes the mark away.
    private var favoriteItem: some View {
        Button {
            toggleFavorite()
        } label: {
            Label {
                Text(favoriteLabel)
            } icon: {
                Image(icon: isFavorite ? .favoriteFilled : .favorite)
            }
        }
        .tint(.textPrimary)
        .sensoryFeedback(.success, trigger: isFavorite)
        .accessibilityAddTraits(isFavorite ? .isSelected : [])
    }

    /// Marks the session as a favorite, or takes the mark away.
    private func toggleFavorite() {
        if reduceMotion {
            isFavorite.toggle()
        } else {
            withAnimation { isFavorite.toggle() }
        }
    }

    /// The menu item that adds the session to a calendar.
    private var calendarItem: some View {
        Button {
        } label: {
            Label {
                Text("Add to Calendar")
            } icon: {
                Image(icon: .calendar)
            }
        }
        .tint(.textPrimary)
    }

    /// The button that shares this session.
    private var shareButton: some View {
        Button {
        } label: {
            Label {
                Text("Share")
            } icon: {
                Image(icon: .share)
            }
        }
        .tint(.textPrimary)
    }

    /// The menu that holds every action except sharing.
    ///
    /// Each item has a title and a symbol, and the favorite item names what it does now.
    private var moreMenu: some View {
        Menu {
            favoriteItem

            calendarItem

            if !session.isInMainRoom {
                findRoomItem
            }
        } label: {
            Label {
                Text("More")
            } icon: {
                Image(icon: .more)
            }
        }
        .tint(.textPrimary)
    }

    /// The menu item that pushes the venue page.
    private var findRoomItem: some View {
        Button {
            showsVenue = true
        } label: {
            Label {
                Text("Find the Room")
            } icon: {
                Image(icon: .location)
            }
        }
        .tint(.textPrimary)
    }
}
