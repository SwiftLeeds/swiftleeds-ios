#if os(iOS)
import Foundation
import SFSafeSymbols
import SwiftUI
import Testing
import UIDesign
import UIKit

@MainActor
@Suite
struct AvatarGroupAccessibilityTests {
    /// The status of an avatar whose person has checked in.
    private static let checkedIn = AvatarStatus("Checked in")

    /// The status of an avatar whose person is on the waiting list.
    private static let waitlisted = AvatarStatus(
        "Waitlisted",
        icon: Icon(.exclamationmarkCircleFill),
        family: .warning,
    )

    /// The names the groups show, in order.
    private static let people = [
        PersonNameComponents(givenName: "Ada", familyName: "Archer"),
        PersonNameComponents(givenName: "Blake", familyName: "Brooks"),
        PersonNameComponents(givenName: "Casey", familyName: "Cole"),
        PersonNameComponents(givenName: "Devon", familyName: "Drake"),
        PersonNameComponents(givenName: "Ellis", familyName: "East"),
    ]

    @Test
    func whenGroupHasNoStatuses_shouldAddNoElement() throws {
        let elements = try AccessibilityTree.elements(of: Self.row(count: 3, statuses: []))

        #expect(elements.count == 1)
        let element = try #require(elements.first)
        #expect(element.label == "Ada Archer and 2 others")
        #expect(element.traits == .staticText)
    }

    @Test
    func whenAvatarHasStatus_shouldReadStatusAsImageElement() throws {
        let elements = try AccessibilityTree.elements(of: Self.row(count: 3, statuses: [Self.checkedIn]))

        #expect(elements.count == 2)
        let status = try #require(elements.first)
        #expect(status.label == "Checked in")
        #expect(status.traits == .image)
        #expect(elements.last?.label == "Ada Archer and 2 others")
    }

    @Test
    func whenTwoAvatarsHaveStatuses_shouldReadInLeadingOrder() throws {
        let elements = try AccessibilityTree.elements(
            of: Self.row(count: 3, statuses: [Self.checkedIn, Self.waitlisted])
        )

        #expect(elements.map(\.label) == ["Checked in", "Waitlisted", "Ada Archer and 2 others"])
        #expect(elements.dropLast().allSatisfy { $0.traits == .image })
    }

    @Test
    func whenGroupOverflows_shouldNotReadCount() throws {
        let elements = try AccessibilityTree.elements(
            of: Self.row(count: 5, statuses: [Self.checkedIn, Self.waitlisted])
        )

        #expect(elements.map(\.label) == ["Checked in", "Waitlisted", "Ada Archer and 4 others"])
    }

    @Test
    func whenGroupIsEmpty_shouldAddNoElement() throws {
        let elements = try AccessibilityTree.elements(of: AvatarGroup {})

        #expect(elements.isEmpty)
    }

    @Test
    func whenGroupHasOneAvatarWithStatus_shouldAddOneElement() throws {
        let elements = try AccessibilityTree.elements(
            of: AvatarGroup {
                Avatar(url: nil, size: .small, status: Self.checkedIn, fallback: .initials(Self.people[0]))
            }
        )

        #expect(elements.count == 1)
        let element = try #require(elements.first)
        #expect(element.label == "Checked in")
        #expect(element.traits == .image)
    }

    /// Returns a group of avatars beside the names it stands for.
    ///
    /// - Parameters:
    ///   - count: How many people the group holds.
    ///   - statuses: The statuses of the first people, in order. The rest have none.
    /// - Returns: A row with the group, then one line of text naming the people.
    private static func row(count: Int, statuses: [AvatarStatus]) -> some View {
        HStack {
            AvatarGroup {
                ForEach(0..<count, id: \.self) { index in
                    Avatar(
                        url: nil,
                        size: .small,
                        status: index < statuses.count ? statuses[index] : nil,
                        fallback: .initials(people[index % people.count]),
                    )
                }
            }
            Text("Ada Archer and \(count - 1) others")
        }
    }
}
#endif
