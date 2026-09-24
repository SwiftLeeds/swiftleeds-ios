import SwiftUI
import UIDesign

/// A view that shows a person's own standing at the conference.
struct ProfileScreen: View {
    /// The person this screen describes.
    let attendee: SampleAttendee

    /// How the halo's outer edge meets the screen behind it.
    var haloEdge: HaloEdge = .hard

    /// How thick the halo is around an avatar that is the screen's subject.
    private static let haloWidth: CGFloat = 5

    var body: some View {
        ScrollView {
            VStack(spacing: .xLarge) {
                header
                groups
            }
            .padding(.horizontal, .large)
            .padding(.bottom, .large)
        }
        .background { AmbientBackground() }
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

    /// What the conference holds about this person.
    private var groups: some View {
        VStack(spacing: .large) {
            group("Conference") {
                row("Ticket", value: attendee.ticket)
                separator
                row("Saved sessions", value: attendee.savedSessions)
            }

            group("Details") {
                row("Name", value: attendee.name)
                separator
                row("Email", value: attendee.email)
            }
        }
    }

    /// The hairline between one row and the next, inset to the text.
    private var separator: some View {
        Divider().padding(.leading, CGFloat(Spacing.large))
    }

    /// Returns a heading with a run of rows grouped under it.
    ///
    /// - Parameters:
    ///   - title: The heading's text.
    ///   - content: A content builder that creates the rows under the heading.
    private func group(
        _ title: String,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: .small) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.textPrimary)

            VStack(spacing: 0) {
                content()
            }
            .contentGroup()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Returns one thing the conference holds, with the value beside its name.
    ///
    /// - Parameters:
    ///   - title: What the value is called.
    ///   - value: The value itself, as the row prints it.
    private func row(_ title: String, value: String) -> some View {
        LabeledContent(title, value: value)
            .font(.body)
            .foregroundStyle(.textPrimary)
            .padding(.large)
    }
}
