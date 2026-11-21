#if os(watchOS)
import Foundation
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign

@MainActor
@Suite(.snapshots(record: .never)) struct AvatarGroupWatchSnapshotTests {
    /// Six made-up people whose initials differ, so the image can tell them apart.
    private static let people = [
        PersonNameComponents(givenName: "Ada", familyName: "Archer"),
        PersonNameComponents(givenName: "Blake", familyName: "Brooks"),
        PersonNameComponents(givenName: "Casey", familyName: "Cole"),
        PersonNameComponents(givenName: "Devon", familyName: "Drake"),
        PersonNameComponents(givenName: "Ellis", familyName: "East"),
        PersonNameComponents(givenName: "Frankie", familyName: "Fox"),
    ]

    @Test func whenThreeAvatars_shouldFitTheScreen() {
        assertSnapshots(of: Self.group(of: 3))
    }

    @Test func whenFiveAvatars_shouldShowCount() {
        assertSnapshots(of: Self.group(of: 5))
    }

    @Test func whenIncreaseContrastIsOn_shouldOutlineCount() {
        let view = Self.group(of: 5)
            .environment(\._colorSchemeContrast, .increased)

        assertSnapshots(of: view)
    }

    /// Returns a group of small avatars with initials.
    ///
    /// - Parameter count: How many people the group holds. The names repeat after six.
    /// - Returns: A group that shows two avatars and a count when `count` is above three.
    private static func group(of count: Int) -> some View {
        AvatarGroup {
            ForEach(0..<count, id: \.self) { index in
                Avatar(url: nil, size: .small, fallback: .initials(people[index % people.count]))
            }
        }
    }
}
#endif
