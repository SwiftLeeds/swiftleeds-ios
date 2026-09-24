#if os(iOS)
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign

@MainActor
@Suite(.snapshots(record: .never)) struct NameplateSnapshotTests {
    // A nameplate fills the width it is given, so every test states one. Without it the helper
    // renders the natural width, where the title never wraps and the reflow never appears.
    private static let rowWidth: CGFloat = 343

    @Test func nameplate() {
        let view = Nameplate(Self.name, detail: Self.company) {
            Avatar(url: nil, size: AvatarSize.medium, fallback: .initials(Self.nameComponents))
        }

        assertSnapshots(of: row(view))
    }

    // Nothing should sit where the detail would be, and the title should stay on the icon's center.
    @Test func withoutDetail() {
        let view = Nameplate(Self.name) {
            Avatar(url: nil, size: AvatarSize.medium, fallback: .initials(Self.nameComponents))
        }

        assertSnapshots(of: row(view))
    }

    // A larger avatar as well as a larger title, because that is the pairing the style asks for.
    @Test func prominentStyle() {
        let view = Nameplate(Self.name, detail: Self.company) {
            Avatar(url: nil, size: AvatarSize.large, fallback: .initials(Self.nameComponents))
        }
        .nameplateStyle(.prominent)

        assertSnapshots(of: row(view))
    }

    // The mark sits on the avatar's lower trailing edge, where the title could crowd it.
    @Test func withStatus() {
        let view = Nameplate(Self.name, detail: Self.company) {
            Avatar(
                url: nil,
                size: AvatarSize.medium,
                status: AvatarStatus("Checked in"),
                fallback: .initials(Self.nameComponents)
            )
        }

        assertSnapshots(of: row(view))
    }

    // The narrowest width we design for. One row, the avatar at its smallest, nothing else.
    @Test func nameplateCompact() {
        let view = Nameplate(Self.name, detail: Self.company) {
            Avatar(url: nil, size: AvatarSize.small, fallback: .initials(Self.nameComponents))
        }

        assertCompactSnapshots(of: view)
    }

    private func row(_ view: some View) -> some View {
        view.frame(width: Self.rowWidth)
    }

    private static let name = "Ada Archer"
    private static let company = "Northern Software"
    private static let nameComponents = PersonNameComponents(givenName: "Ada", familyName: "Archer")
}
#endif
