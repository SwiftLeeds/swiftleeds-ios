#if os(iOS)
import Foundation
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign

@MainActor
@Suite(.snapshots(record: .never)) struct CountdownSnapshotTests {
    /// The moment every test counts towards.
    private static let start = Date(timeIntervalSinceReferenceDate: 800_000_000)

    /// The countdown in British English with the clock pinned to a time before the start.
    ///
    /// - Parameter timeLeft: How long before the start the pinned clock reads.
    /// - Returns: A countdown on the primary surface, with room around it.
    private func countdown(timeLeft: TimeInterval) -> some View {
        Countdown(to: Self.start)
            .countdownNow(.fixed(Self.start.addingTimeInterval(-timeLeft)))
            .environment(\.locale, Locale(identifier: "en_GB"))
            .padding(.lg)
            .background(.surface)
    }

    @Test func whenTwelveMinutesRemain_shouldDrawInTwelveMin() {
        assertSnapshots(of: countdown(timeLeft: 12 * 60))
    }
}
#endif
