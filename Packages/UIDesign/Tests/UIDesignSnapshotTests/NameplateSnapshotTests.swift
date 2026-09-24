#if os(iOS)
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign

@MainActor
@Suite(.snapshots(record: .never)) struct NameplateSnapshotTests {
    @Test func nameplate() {
        let view = Nameplate(Self.name, detail: Self.company) {
            Avatar(url: nil, size: AvatarSize.medium, fallback: .initials(Self.nameComponents))
        }

        assertSnapshots(of: row(view))
    }

    /// Checks that nothing sits where the detail would be, and that the title
    /// stays on the icon's center.
    @Test func withoutDetail() {
        let view = Nameplate(Self.name) {
            Avatar(url: nil, size: AvatarSize.medium, fallback: .initials(Self.nameComponents))
        }

        assertSnapshots(of: row(view))
    }

    /// Checks the larger avatar as well as the larger title, because that is
    /// the pairing the style asks for.
    @Test func prominentStyle() {
        let view = Nameplate(Self.name, detail: Self.company) {
            Avatar(url: nil, size: AvatarSize.large, fallback: .initials(Self.nameComponents))
        }
        .nameplateStyle(.prominent)

        assertSnapshots(of: row(view))
    }

    /// Checks the mark on the avatar's lower trailing edge, where the title
    /// could crowd it.
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

    /// Checks the loading state, which is the nameplate itself redacted.
    ///
    /// Three rows, because a skeleton is judged as a group: the bars should
    /// read as rows and the circles should stay circles.
    @Test func redactedWhileLoading() {
        let view = VStack(spacing: Spacing.large) {
            ForEach(Self.sample, id: \.self) { name in
                Nameplate(name, detail: Self.company) {
                    Avatar(
                        url: nil,
                        size: AvatarSize.medium,
                        fallback: .initials(Self.nameComponents)
                    )
                }
            }
        }
        .redacted(reason: .placeholder)

        assertSnapshots(of: row(view))
    }

    /// Checks the heading while it loads, the one place a row's height comes
    /// from padding as well as from the text.
    @Test func redactedWhileLoadingProminent() {
        let view = Nameplate(Self.name, detail: Self.company) {
            Avatar(url: nil, size: AvatarSize.large, fallback: .initials(Self.nameComponents))
        }
        .nameplateStyle(.prominent)
        .redacted(reason: .placeholder)

        assertSnapshots(of: row(view))
    }

    /// Checks the narrowest width we design for: one row, the avatar at its
    /// smallest, nothing else.
    @Test func nameplateCompact() {
        let view = Nameplate(Self.name, detail: Self.company) {
            Avatar(url: nil, size: AvatarSize.small, fallback: .initials(Self.nameComponents))
        }

        assertCompactSnapshots(of: view)
    }

    /// Returns the view at the width a list row gets.
    ///
    /// - Parameter view: The view to size.
    private func row(_ view: some View) -> some View {
        view.frame(width: rowWidth)
    }

    /// A made-up name, held in a variable so it binds to the initializer that
    /// does not localize.
    private static let name = "Ada Archer"

    /// A made-up company, shown as the detail line.
    private static let company = "Northern Software"

    /// The name in parts, so the avatar can abbreviate it.
    private static let nameComponents = PersonNameComponents(
        givenName: "Ada",
        familyName: "Archer"
    )

    /// Three made-up names, so a skeleton's bars vary in width the way real
    /// rows do.
    private static let sample = ["Ada Archer", "Blake Brooks", "Casey Cole"]
}
#endif
