import SwiftUI
import UIDesign

/// A view that shows one avatar under every halo treatment at once.
///
/// It draws at the size and the ring width the schedule's bar item uses, on
/// the same wash, so the treatments can be judged against each other rather
/// than one after another.
struct HaloComparison: View {
    /// The conference's own colors, paired for a halo.
    ///
    /// The second color sits 55 degrees around the hue circle from the brand's
    /// red, the same separation the organizer's purple and blue use. That
    /// direction lands on pink; the other lands on the gold a sponsor tier
    /// already holds.
    static let brand = ConferenceRole(
        name: "SwiftLeeds",
        colors: [.brandPrimary, .init(red: 0.95, green: 0.27, blue: 0.86)]
    )

    /// How thick the ring is, matching the schedule's bar item.
    private static let haloWidth: CGFloat = 1.5

    /// The standing whose colors every treatment draws.
    let role: ConferenceRole

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: .xLarge) {
                    group("Edge, at 70%") {
                        tile("Hard", edge: .hard)
                        tile("Soft", edge: .soft)
                        tile("Feathered", edge: .feathered)
                    }

                    group("Strength, feathered") {
                        tile("70%", strength: 0.7)
                        tile("60%", strength: 0.6)
                        tile("50%", strength: 0.5)
                    }

                    group("Strength, feathered, adding light") {
                        tile("70%", strength: 0.7, glows: true)
                        tile("60%", strength: 0.6, glows: true)
                        tile("50%", strength: 0.5, glows: true)
                    }
                }
                .padding(.horizontal, .large)
                .padding(.bottom, .large)
            }
            .background { AmbientBackground() }
            .navigationTitle("Halo")
            .navigationSubtitle(role.name)
        }
    }

    /// Returns a heading with a row of treatments under it.
    ///
    /// - Parameters:
    ///   - title: What the row varies.
    ///   - content: A content builder that creates the row's treatments.
    private func group(
        _ title: String,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: .medium) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.textPrimary)

            HStack(alignment: .top, spacing: .medium) {
                content()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Returns one haloed avatar with the words that name its treatment.
    ///
    /// - Parameters:
    ///   - name: What tells this treatment from the others beside it.
    ///   - edge: How the halo's outer edge meets the wash behind it.
    ///   - strength: How strongly the halo draws.
    ///   - glows: Whether the fade adds light rather than painting over.
    private func tile(
        _ name: String,
        edge: HaloEdge = .feathered,
        strength: Double = 0.7,
        glows: Bool = false
    ) -> some View {
        VStack(spacing: .small) {
            MockRoleRing(
                role: role,
                width: Self.haloWidth,
                edge: edge,
                strength: strength,
                glows: glows,
                ring: Circle()
            ) {
                Avatar(
                    url: nil,
                    size: .medium,
                    fallback: .initials(SampleAttendee.signedIn.nameComponents)
                )
            }

            Text(name)
                .font(.caption)
                .foregroundStyle(.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}
