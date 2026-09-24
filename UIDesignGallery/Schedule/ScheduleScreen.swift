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

    /// How the schedule separates one session from the next.
    enum RowStyle: String {
        /// A hairline between rows, which is what Apple's dense list uses.
        case bare

        /// A run of rows on one raised surface, with a picture on each.
        case card
    }

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

    /// How the schedule separates one session from the next.
    var rowStyle: RowStyle = .bare

    /// How the halo's outer edge meets the screen behind it.
    var haloEdge: HaloEdge = .feathered

    /// The screens pushed on top of the schedule.
    @State private var path: [ScheduleDestination] = []

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
            Group {
                switch rowStyle {
                case .bare: bareRows
                case .card: cardedRows
                }
            }
            .background { AmbientBackground() }
            .navigationTitle(conference)
            .navigationSubtitle("Starts in 12 days")
            .navigationDestination(for: ScheduleDestination.self) { destination in
                switch destination {
                case .session(let session):
                    SessionDetailScreen(session: session)
                case .profile:
                    ProfileScreen(attendee: .signedIn, haloEdge: haloEdge)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(value: ScheduleDestination.profile) {
                        // The halo says this person holds a standing at the
                        // conference. Their own profile spells it out, so the
                        // ring is a reminder rather than the only statement.
                        MockRoleRing(
                            role: SampleAttendee.signedIn.role,
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
            if let opensWith {
                path = [opensWith]
            }
        }
    }

    /// The schedule as a dense list, separated by a hairline.
    private var bareRows: some View {
        List {
            Section {
                scopePicker
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }

            Section {
                ForEach(sessions) { session in
                    NavigationLink(value: ScheduleDestination.session(session)) {
                        SessionRow(session: session)
                    }
                    .listRowBackground(Color.clear)
                }
            } header: {
                dayHeader
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    /// The schedule as one raised surface, with a picture on every row.
    private var cardedRows: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .large) {
                scopePicker

                VStack(alignment: .leading, spacing: .small) {
                    dayHeader

                    VStack(spacing: 0) {
                        ForEach(Array(sessions.enumerated()), id: \.element.id) { index, session in
                            NavigationLink(value: ScheduleDestination.session(session)) {
                                SessionRow(session: session, showsArtwork: true)
                                    .padding(.large)
                            }
                            .buttonStyle(.plain)

                            if index < sessions.count - 1 {
                                Divider().padding(.leading, CGFloat(Spacing.large))
                            }
                        }
                    }
                    .contentGroup()
                }
            }
            .padding(.horizontal, .large)
            .padding(.bottom, .large)
        }
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
            // An active filter fills and tints its own button, which is how
            // the system marks one. A separate chip saying so is not Apple's.
            Label(
                "Filter",
                systemImage: isFiltered
                    ? "line.3.horizontal.decrease.circle.fill"
                    : "line.3.horizontal.decrease"
            )
        }
        .tint(isFiltered ? AnyShapeStyle(.brandPrimary) : AnyShapeStyle(.textPrimary))
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

            Label("18°", systemImage: "sun.max")
                .font(.subheadline)
                .foregroundStyle(.textSecondary)
                .textCase(nil)
        }
    }
}
