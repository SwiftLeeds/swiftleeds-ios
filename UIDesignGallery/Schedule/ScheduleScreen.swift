import SwiftUI
import UIDesign

/// A view that lists the conference's sessions, a day at a time.
struct ScheduleScreen: View {
    /// Which sessions the schedule lists.
    private enum Filter: Hashable {
        /// Every session at the conference.
        case all

        /// Only the sessions this person saved.
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

    /// The screen the schedule opens with already pushed, if any.
    let opensWith: ScheduleDestination?

    /// How the halo's outer edge meets the screen behind it.
    var haloEdge: HaloEdge = .feathered

    /// The sessions pushed on top of the schedule.
    @State private var path: [SampleSession] = []

    /// Whether the signed-in person's profile is on screen.
    @State private var showsProfile = false

    /// The filter the segmented control shows.
    @State private var filter: Filter = .all

    /// Which conference's schedule the screen shows.
    @State private var conference = ScheduleScreen.conferences[0]

    /// What the schedule puts first.
    @State private var order: Order = .time

    /// The kinds of session the schedule includes.
    @State private var includedKinds: Set<String> = ["Talk", "Lightning", "Workshop"]

    var body: some View {
        NavigationStack(path: $path) {
            rows
            .navigationTitle(conference)
            .navigationSubtitle("Starts in 12 days")
            .navigationDestination(for: SampleSession.self) { session in
                SessionDetailScreen(session: session)
            }
            .sheet(isPresented: $showsProfile) { profileSheet }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showsProfile = true
                    } label: {
                        // The halo says this person holds a standing at the
                        // conference. Their own profile spells it out, so the
                        // ring is a reminder rather than the only statement.
                        MockRoleRing(
                            role: SampleAttendee.signedIn.role,
                            width: Self.haloWidth,
                            edge: haloEdge,
                            ring: Circle()
                        ) {
                            Avatar(
                                url: nil,
                                size: .medium,
                                fallback: .initials(SampleAttendee.signedIn.nameComponents)
                            )
                        }
                    }
                    .accessibilityLabel("Account, \(SampleAttendee.signedIn.role.name)")
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
                    Button {} label: {
                        Label("Notifications", systemImage: "bell")
                    }
                    .tint(.textPrimary)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {} label: {
                        Label("Ticket", systemImage: "ticket")
                    }
                    .tint(.textPrimary)
                }
            }
        }
        .onAppear {
            switch opensWith {
            case .session(let session): path = [session]
            case .profile: showsProfile = true
            case nil: break
            }
        }
    }

    /// The signed-in person's profile, over the schedule rather than after it.
    ///
    /// A profile is not the next step in reading the schedule, so it arrives as
    /// a sheet and leaves by the same gesture it came in on.
    private var profileSheet: some View {
        NavigationStack {
            ProfileScreen(attendee: .signedIn, haloEdge: haloEdge)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Close", systemImage: "xmark") { showsProfile = false }
                            .tint(.textPrimary)
                    }
                }
        }
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
    private static let everyKind: Set<String> = ["Talk", "Lightning", "Workshop"]

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
        let kept = SampleSession.dayOne.filter { includedKinds.contains($0.kind ?? "Talk") }
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
                ForEach(["Talk", "Lightning", "Workshop"], id: \.self) { kind in
                    Toggle(kind, isOn: binding(for: kind))
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
    private func binding(for kind: String) -> Binding<Bool> {
        Binding(
            get: { includedKinds.contains(kind) },
            set: { isOn in
                if isOn {
                    includedKinds.insert(kind)
                } else {
                    includedKinds.remove(kind)
                }
            }
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
