import SwiftUI
import UIDesign

/// A view that lists the conference's sessions, a day at a time.
struct ScheduleScreen: View {
    /// Which sheet the schedule shows, or nil for none.
    private enum Sheet: Equatable, Hashable, Identifiable {
        /// What a person can change about the app.
        case settings

        /// The screen that signs a person in with their ticket.
        case signIn(SignInState)

        /// A ticket, shown full size.
        case ticket(SampleTicket)

        var id: Self { self }
    }

    /// Which sessions the schedule lists.
    private enum Filter: Hashable {
        /// Every session at the conference.
        case all

        /// Only the sessions this person favourited.
        case mine
    }

    /// What the schedule puts first.
    private enum Order: Hashable {
        /// The order the sessions run in.
        case time

        /// Alphabetical by session title.
        case title
    }

    /// How thick the halo is around an avatar that is a bar item.
    ///
    /// It is thinner than the one on a profile, in proportion and in points.
    /// The halo is a reminder here rather than the screen's subject, and the
    /// fade spreads from the width, so one value quietens both.
    private static let haloWidth: CGFloat = 1.5

    /// How far the avatar moves back to line up with the title under it.
    ///
    /// A bar item reserves the margin its glass capsule would need. Hiding the
    /// capsule leaves the margin behind, which sets the avatar in from the
    /// title.
    private static let avatarLead: CGFloat = -14

    /// The conferences a person can look back at, most recent first.
    ///
    /// These are display text, for the reason `SampleSession` gives.
    private static let conferences = ["SwiftLeeds 2026", "SwiftLeeds 2025", "SwiftLeeds 2024"]

    /// The kinds of session the filter menu lists, in the order it lists them.
    private static let listedKinds: [SessionKind] = [.talk, .lightningTalk, .workshop]

    /// The screen the schedule opens with already pushed, if any.
    let opensWith: ScheduleDestination?

    /// How the halo's outer edge meets the screen behind it.
    var haloEdge: HaloEdge = .feathered

    /// Whether the role band on a ticket draws the role's texture.
    var bandVariant: BandVariant = .plain

    /// Whether a person page opens with the person already a favourite.
    var opensFavorite = false

    /// Whether a person page opens with the bio in full.
    var opensBioExpanded = false

    /// Whether a session detail opens with its summary in full.
    var opensSummaryExpanded = false

    /// The screens pushed on top of the schedule.
    ///
    /// The schedule pushes three kinds of thing, a session, a person and a
    /// sponsor, so the path is untyped.
    @State private var path = NavigationPath()

    /// The sheet the schedule shows, or nil for none.
    @State private var sheet: Sheet?

    /// The screens pushed on top of Settings.
    ///
    /// Settings pushes three kinds of thing, a person, a resource and a
    /// category, so the path is untyped. A typed path would take one of them
    /// and drop the others.
    @State private var settingsPath = NavigationPath()

    /// The filter the segmented control shows.
    @State private var filter: Filter = .all

    /// Which conference's schedule the screen shows.
    @State private var conference = ScheduleScreen.conferences[0]

    /// What the schedule puts first.
    @State private var order: Order = .time

    /// The kinds of session the schedule includes.
    @State private var includedKinds = Set(ScheduleScreen.listedKinds)

    var body: some View {
        NavigationStack(path: $path) {
            rows
                .navigationTitle(conference)
                .navigationSubtitle("Starts in 12 days")
                .navigationDestination(for: SampleSession.self) { session in
                    SessionDetailScreen(
                        session: session,
                        opensSummaryExpanded: opensSummaryExpanded,
                        showSpeaker: { path.append($0) },
                    )
                }
                .navigationDestination(for: SamplePerson.self) { person in
                    PersonScreen(
                        person: person,
                        opensFavorite: opensFavorite,
                        opensBioExpanded: opensBioExpanded,
                    )
                }
                .navigationDestination(for: SampleSponsor.self) { sponsor in
                    NotYetDesigned(destination: .sponsors)
                        .navigationTitle(sponsor.name)
                }
                .sheet(item: $sheet) { item in
                    switch item {
                    case .settings: settingsSheet
                    case .signIn(let state): signInSheet(opensWith: state)
                    case .ticket(let ticket): ticketSheet(for: ticket)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            sheet = .settings
                        } label: {
                            // The halo says this person holds a standing at the
                            // conference. Their own profile spells it out, so the
                            // ring is a reminder rather than the only statement.
                            MockRoleRing(
                                role: SampleAttendee.signedIn.role,
                                width: Self.haloWidth,
                                edge: haloEdge,
                                ring: Circle(),
                            ) {
                                Avatar(
                                    url: nil,
                                    size: .medium,
                                    fallback: .initials(SampleAttendee.signedIn.nameComponents),
                                )
                            }
                        }
                        .accessibilityLabel("Settings, \(SampleAttendee.signedIn.role.name)")
                        .padding(.leading, Self.avatarLead)
                    }
                    // Apple's shape rule is a circle for one bar item and a capsule
                    // for a group. The system draws a wide capsule around a lone
                    // custom label, and `buttonBorderShape(.circle)` does not move
                    // it, so the avatar draws its own circle instead.
                    .sharedBackgroundVisibility(.hidden)

                    ToolbarTitleMenu {
                        Picker("Conference", selection: $conference) {
                            ForEach(Self.conferences, id: \.self) { name in
                                Text(name).tag(name)
                            }
                        }
                    }

                    // Chrome glyphs stay neutral. The tint is reserved for the
                    // selected tab and for an action that changes something.
                    ToolbarItem(placement: .topBarTrailing) {
                        filterMenu
                    }

                    // Apple groups related actions in one capsule. The filter changes
                    // what the schedule shows; the two beside it open something else.
                    ToolbarSpacer(.fixed, placement: .topBarTrailing)

                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                        } label: {
                            Label("Notifications", systemImage: "bell")
                        }
                        .tint(.textPrimary)
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            sheet = .ticket(.signedIn)
                        } label: {
                            Label("Ticket", systemImage: "ticket")
                        }
                        .tint(.textPrimary)
                    }
                }
        }
        .onAppear {
            switch opensWith {
            case .session(let session): path.append(session)
            case .person(let person): path.append(person)
            case .settings: sheet = .settings
            case .profile:
                sheet = .settings
                settingsPath.append(SampleAttendee.signedIn)
            case .settingsCategory(let category):
                sheet = .settings
                settingsPath.append(category)
            case .signIn(let state): sheet = .signIn(state)
            case .ticket(let ticket): sheet = .ticket(ticket)
            case nil: break
            }
        }
    }

    /// Settings, over the schedule rather than after it.
    ///
    /// Settings is not the next step in reading the schedule, so it arrives as
    /// a sheet and leaves by the same gesture it came in on. The profile sits
    /// one step inside it, reached from the account at the top.
    private var settingsSheet: some View {
        NavigationStack(path: $settingsPath) {
            SettingsScreen(attendee: .signedIn)
                .navigationDestination(for: SampleAttendee.self) { attendee in
                    ProfileScreen(attendee: attendee, haloEdge: haloEdge)
                }
                .navigationDestination(for: SampleResource.self) { resource in
                    NotYetDesigned(symbol: resource.symbol)
                        .navigationTitle(resource.title)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Close", systemImage: "xmark") { sheet = nil }
                            .tint(.textPrimary)
                    }
                }
        }
    }

    /// Sign in, over the schedule rather than after it.
    ///
    /// - Parameter state: The state the screen opens in.
    private func signInSheet(opensWith state: SignInState) -> some View {
        NavigationStack {
            SignInScreen(opensWith: state)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Close", systemImage: "xmark") { sheet = nil }
                            .tint(.textPrimary)
                    }
                }
        }
    }

    /// A ticket, over the schedule rather than after it.
    ///
    /// - Parameter ticket: The ticket to show.
    private func ticketSheet(for ticket: SampleTicket) -> some View {
        NavigationStack {
            TicketScreen(ticket: ticket, bandVariant: bandVariant)
                .navigationTitle("Ticket")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Close", systemImage: "xmark") { sheet = nil }
                            .tint(.textPrimary)
                    }
                }
        }
        .presentationSizing(.form)
    }

    /// The schedule as a dense list, separated by a hairline.
    private var rows: some View {
        List {
            Section {
                scopePicker
                    .listRowSeparator(.hidden)
            }

            Section {
                ForEach(sessions) { session in
                    NavigationLink(value: session) {
                        SessionRow(session: session)
                    }
                }
            } header: {
                dayHeader
            }
        }
        .listStyle(.plain)
    }

    /// Every kind of session, which is what no filter means.
    private static let everyKind = Set(listedKinds)

    /// Whether the schedule is showing less than everything.
    private var isFiltered: Bool {
        includedKinds != Self.everyKind || order != .time
    }

    /// The control that narrows the schedule to this person's own sessions.
    private var scopePicker: some View {
        Picker("Sessions", selection: $filter) {
            Text("All").tag(Filter.all)
            Text("Mine").tag(Filter.mine)
        }
        .pickerStyle(.segmented)
    }

    /// The sessions this day, once the filter and the order have been applied.
    private var sessions: [SampleSession] {
        let kept = SampleSession.dayOne.filter { includedKinds.contains($0.kind) }
        switch order {
        case .time: return kept
        case .title: return kept.sorted { $0.title < $1.title }
        }
    }

    /// The menu that filters the schedule and orders it.
    ///
    /// An active filter tints its glyph. A separate chip saying so is not
    /// Apple's.
    private var filterMenu: some View {
        Menu {
            Picker("Order", selection: $order) {
                Text("Time").tag(Order.time)
                Text("Title").tag(Order.title)
            }

            Section("Kind") {
                ForEach(Self.listedKinds, id: \.self) { kind in
                    Toggle(kind.displayName, isOn: binding(for: kind))
                }
            }
        } label: {
            Label("Filter", systemImage: "line.3.horizontal.decrease")
        }
        .tint(isFiltered ? .brandPrimary : .textPrimary)
    }

    /// Returns whether the schedule includes a kind of session.
    ///
    /// - Parameter kind: The kind of session to include or leave out.
    private func binding(for kind: SessionKind) -> Binding<Bool> {
        Binding(
            get: { includedKinds.contains(kind) },
            set: { isOn in
                if isOn {
                    includedKinds.insert(kind)
                } else {
                    includedKinds.remove(kind)
                }
            },
        )
    }

    /// The day's heading, with the weather beside it.
    private var dayHeader: some View {
        HStack {
            Text("Day 1")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.textPrimary)
                .textCase(nil)

            Spacer(minLength: 0)

            Label(SampleVenue.temperature, systemImage: SampleVenue.weatherSymbol)
                .font(.subheadline)
                .foregroundStyle(.textSecondary)
                .textCase(nil)
                .accessibilityLabel(SampleVenue.weather)
        }
    }
}
