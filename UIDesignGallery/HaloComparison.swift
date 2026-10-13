import SwiftUI
import UIDesign

/// A view that shows one avatar under every halo treatment at once.
///
/// It draws at the size and the ring width the schedule's bar item uses, on
/// the same background, so the treatments can be judged against each other
/// rather than one after another.
struct HaloComparison: View {
    /// The brand's red run toward a pink.
    ///
    /// The pink sits 55 degrees around the hue circle from the red, the same
    /// separation the organizer's purple and blue use. No role holds a pink.
    static let brandPink = ConferenceRole(
        name: "Brand and pink",
        colors: [.brandPrimary, .init(red: 0.95, green: 0.27, blue: 0.86)],
    )

    /// The brand's red run toward the conference's own gold.
    ///
    /// The gold is the departure board on the conference's site, `#F9D557`,
    /// which sits 44 degrees around the hue circle from the red.
    static let brandGold = ConferenceRole(
        name: "Brand and gold",
        colors: [.brandPrimary, .init(red: 0.976, green: 0.835, blue: 0.341)],
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
        @ViewBuilder content: () -> some View,
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
    ///   - edge: How the halo's outer edge meets the screen behind it.
    ///   - strength: How strongly the halo draws.
    ///   - glows: Whether the fade adds light rather than painting over.
    private func tile(
        _ name: String,
        edge: HaloEdge = .feathered,
        strength: Double = 0.7,
        glows: Bool = false,
    ) -> some View {
        VStack(spacing: .small) {
            MockRoleRing(
                role: role,
                width: Self.haloWidth,
                edge: edge,
                strength: strength,
                glows: glows,
                ring: Circle(),
            ) {
                Avatar(
                    url: nil,
                    size: .medium,
                    fallback: .initials(SampleAttendee.signedIn.nameComponents),
                )
            }

            Text(name)
                .font(.caption)
                .foregroundStyle(.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}
