#if os(iOS)
import Foundation
import LocalUI
import SwiftUI
import Testing

@MainActor
@Suite struct LocationCardSnapshotTests {
    @Test func withLink() throws {
        let view = LocationCard(
            symbolName: "takeoutbag.and.cup.and.straw.fill",
            name: "Trinity Kitchen",
            websiteURL: try #require(URL(string: "https://example.com")),
        )

        assertSheetSnapshots(of: view)
    }
}
#endif
