import SwiftUI
import UIDesign

/// A view that shows a person's own standing at the conference.
struct ProfileScreen: View {
    /// The person this screen describes.
    let attendee: SampleAttendee

    /// How the halo's outer edge meets the screen behind it.
    var haloEdge: HaloEdge = .feathered

    /// How thick the halo is around an avatar that is the screen's subject.
    private static let haloWidth: CGFloat = 5

    var body: some View {
        List {
            Section {
                header
                    .listRowInsets(EdgeInsets())
                    // The header is the screen's subject, not one of its rows,
                    // so it sits on the page rather than on a card.
                    .listRowBackground(Color.clear)
            }

            Section("Conference") {
                LabeledContent("Ticket", value: attendee.ticket)
                LabeledContent("Saved sessions", value: attendee.savedSessions)
            }

            Section("Details") {
                LabeledContent("Name", value: attendee.name)
                LabeledContent("Email", value: attendee.email)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(attendee.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {}
                    .tint(.textPrimary)
            }
        }
    }

    /// Who this person is, and what the conference calls them.
    ///
    /// The halo is hidden from VoiceOver, because the badge under it already
    /// reads the role out, and the name sits directly below the avatar.
    private var header: some View {
        VStack(spacing: .medium) {
            MockRoleRing(
                role: attendee.role,
                width: Self.haloWidth,
                edge: haloEdge,
                ring: Circle()
            ) {
                Avatar(url: nil, size: .xLarge, fallback: .initials(attendee.nameComponents))
            }
            .accessibilityHidden(true)

            VStack(spacing: .xxSmall) {
                Text(attendee.name)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.textPrimary)

                Text(attendee.detail)
                    .font(.subheadline)
                    .foregroundStyle(.textSecondary)
            }

            badges

            VStack(spacing: .xxSmall) {
                Text(attendee.number)
                Text(attendee.joined)
            }
            .font(.caption)
            .foregroundStyle(.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
        .padding(.horizontal, .large)
        .padding(.top, .large)
    }

    /// The standings this person holds, side by side while they fit.
    private var badges: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: .small) {
                MockRoleBadge(role: attendee.role)
                MockNeutralBadge(text: attendee.tenure)
            }

            VStack(spacing: .small) {
                MockRoleBadge(role: attendee.role)
                MockNeutralBadge(text: attendee.tenure)
            }
        }
    }

}
