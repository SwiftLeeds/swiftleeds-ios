#if os(iOS)
import SwiftUI
import Testing
import UIDesign
import UIKit

@MainActor
@Suite
struct RingedAvatarStyleAccessibilityTests {
    /// The accessibility elements of one view, drawn in the ringed style and in the default style.
    private struct Trees {
        /// The elements of the view with the ringed style set.
        let ringed: [AccessibilityTree.Element]

        /// The elements of the same view with no style set.
        let plain: [AccessibilityTree.Element]
    }

    /// Reads the accessibility elements of one view, ringed and in the default style.
    ///
    /// - Parameter content: The view to read. It runs once for each style.
    /// - Returns: The elements of the ringed view and of the default view.
    /// - Throws: ``AccessibilityTree/SwitchOnError`` when accessibility cannot be turned on.
    private static func trees<Content: View>(
        @ViewBuilder of content: () -> Content
    ) throws(AccessibilityTree.SwitchOnError) -> Trees {
        let ringed = try AccessibilityTree.elements(
            of: content().avatarStyle(.ringed).avatarRingPalette(.blue)
        )
        let plain = try AccessibilityTree.elements(of: content())
        return Trees(ringed: ringed, plain: plain)
    }

    @Test
    func whenRingedAvatarHasNoStatus_shouldAddNoElement() throws {
        let trees = try Self.trees { Avatar(url: nil) }
        #expect(trees.ringed.isEmpty)
        #expect(trees.ringed == trees.plain)
    }

    @Test
    func whenRingedAvatarHasStatus_shouldReadStatusAsOneImageElement() throws {
        let trees = try Self.trees { Avatar(url: nil, status: AvatarStatus("Checked in")) }
        #expect(trees.ringed.count == 1)
        let element = try #require(trees.ringed.first)
        #expect(element.label == "Checked in")
        #expect(element.traits == .image)
        #expect(trees.ringed == trees.plain)
    }

    @Test
    func whenCallerLabelsRingedAvatar_shouldReadCallerLabelAsImage() throws {
        let trees = try Self.trees {
            Avatar(url: nil)
                .accessibilityElement()
                .accessibilityLabel("Ada Archer")
                .accessibilityAddTraits(.isImage)
        }
        #expect(trees.ringed.count == 1)
        let element = try #require(trees.ringed.first)
        #expect(element.label == "Ada Archer")
        #expect(element.traits == .image)
        #expect(trees.ringed == trees.plain)
    }

    @Test
    func whenRingedAvatarIsInNameplate_shouldReadOneElementWithEveryLine() throws {
        let trees = try Self.trees {
            Nameplate("Ada Archer", detail: "Northern Software") {
                Avatar(url: nil, status: AvatarStatus("Checked in"))
            }
        }
        #expect(trees.ringed.count == 1)
        let element = try #require(trees.ringed.first)
        #expect(element.label == "Ada Archer, Northern Software, Checked in")
        #expect(element.traits == .staticText)
        #expect(trees.ringed == trees.plain)
    }

    @Test
    func whenRingedAvatarIsInProminentNameplate_shouldReadOneHeadingElement() throws {
        let trees = try Self.trees {
            Nameplate("Ada Archer", detail: "Northern Software") {
                Avatar(url: nil, status: AvatarStatus("Checked in"))
            }
            .nameplateStyle(.prominent)
        }
        #expect(trees.ringed.count == 1)
        let element = try #require(trees.ringed.first)
        #expect(element.label == "Ada Archer, Northern Software, Checked in")
        #expect(element.traits == [.header, .staticText])
        #expect(trees.ringed == trees.plain)
    }

    @Test
    func whenRingedAvatarIsRedacted_shouldReadAsRedactedDefaultAvatar() throws {
        let trees = try Self.trees {
            Avatar(url: nil, status: AvatarStatus("Checked in"))
                .redacted(reason: .placeholder)
        }
        #expect(trees.ringed == trees.plain)
    }
}
#endif
