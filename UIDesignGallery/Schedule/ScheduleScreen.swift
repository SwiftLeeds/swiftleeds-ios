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

    /// Whether the screen opens with a session's detail already pushed.
    let showsSessionDetail: Bool

    /// The sessions pushed on top of the schedule.
    @State private var path: [SampleSession] = []

    /// The filter the segmented control shows.
    @State private var filter: Filter = .all

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section {
                    Picker("Sessions", selection: $filter) {
                        Text("All").tag(Filter.all)
                        Text("Mine").tag(Filter.mine)
                    }
                    .pickerStyle(.segmented)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }

                Section {
                    ForEach(SampleSession.dayOne) { session in
                        NavigationLink(value: session) {
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
            .background { AmbientBackground() }
            .navigationTitle("SwiftLeeds")
            .navigationSubtitle("Starts in 12 days")
            .navigationDestination(for: SampleSession.self) { session in
                SessionDetailScreen(session: session)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {} label: {
                        Avatar(
                            url: nil,
                            size: .medium,
                            fallback: .initials(.init(givenName: "Ada", familyName: "Archer"))
                        )
                    }
                    .accessibilityLabel("Account")
                }
                .sharedBackgroundVisibility(.hidden)

                // Chrome glyphs stay neutral. The tint is reserved for the
                // selected tab and for an action that changes something.
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
            if showsSessionDetail {
                path = [.opening]
            }
        }
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
