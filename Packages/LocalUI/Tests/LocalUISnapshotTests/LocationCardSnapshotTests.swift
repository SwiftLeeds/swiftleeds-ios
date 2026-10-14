#if os(iOS)
import Foundation
import LocalUI
import Testing

@MainActor
@Suite struct LocationCardSnapshotTests {
    @Test func withLink() throws {
        let view = LocationCard(
            symbolName: "takeoutbag.and.cup.and.straw.fill",
            name: "Trinity Kitchen",
            websiteURL: try #require(URL(string: "https://example.com")),
            dismiss: {},
        )

        assertSheetSnapshots(of: view)
    }

    @Test func withoutLink() {
        let view = LocationCard(
            symbolName: "takeoutbag.and.cup.and.straw.fill",
            name: "Trinity Kitchen",
            websiteURL: nil,
            dismiss: {},
        )

        assertSheetSnapshots(of: view)
    }
}
#endif
