import SwiftUI
import UIDesign

/// A view that rings a subject to show the standing they hold at the
/// conference.
///
/// The ring never carries the meaning on its own. It is paired with the role's
/// name, so a person who cannot tell the colors apart still learns the role,
/// and so VoiceOver has something to read.
struct MockRoleRing<Ring: InsettableShape, Content: View>: View {
    /// The standing this subject holds.
    let role: ConferenceRole

    /// How thick the ring is.
    var width: CGFloat = 3

    /// How the ring's outer edge meets what is behind it.
    var edge: HaloEdge = .hard

    /// How far the ring sits outside the subject.
    ///
    /// Zero by default, so the ring's inner edge meets the subject. A gap lets
    /// whatever is behind the screen show through as a band, which reads as a
    /// mistake rather than as a halo.
    var gap: CGFloat = 0

    /// The shape the ring follows, which matches the subject it goes around.
    let ring: Ring

    /// The subject the ring goes around.
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(width + gap)
            .background { fadedHalo }
            .overlay { crispHalo }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(role.name)
    }

    /// How far a fading edge spreads, as a share of the ring's width.
    private static var spread: CGFloat { 0.75 }

    /// The ring drawn behind the subject and blurred, for an edge that fades.
    ///
    /// It sits behind so the subject, which is opaque, covers the half of the
    /// blur that spreads inward. Only the outer half stays visible, so the
    /// ring dissolves outward and nothing bleeds over the subject.
    @ViewBuilder private var fadedHalo: some View {
        if edge.fades {
            halo.blur(radius: width * Self.spread)
        }
    }

    /// The ring drawn over the subject, for an edge that stays crisp.
    @ViewBuilder private var crispHalo: some View {
        if edge.isCrisp {
            halo
        }
    }

    /// The ring itself, in the colors the role runs between.
    private var halo: some View {
        ring.strokeBorder(
            AngularGradient(colors: role.colors + [role.colors[0]], center: .center),
            lineWidth: width
        )
    }
}
