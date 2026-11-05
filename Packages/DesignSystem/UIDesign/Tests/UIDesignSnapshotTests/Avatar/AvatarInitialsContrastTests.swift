#if os(iOS)
import Foundation
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign
import UIKit

/// Tests that an avatar's initials reach the text contrast floor on every surface.
@MainActor
@Suite
struct AvatarInitialsContrastTests {
    /// A surface an avatar can sit on.
    private enum Surface: CaseIterable {
        /// The main background.
        case surface
        /// Content layered on top of the main background.
        case secondarySurface
        /// Content layered on top of secondary backgrounds.
        case tertiarySurface
        /// The main background of a grouped interface.
        case groupedSurface
        /// Content layered on top of the main background of a grouped interface.
        case secondaryGroupedSurface
        /// Content layered on top of secondary backgrounds of a grouped interface.
        case tertiaryGroupedSurface

        /// The style that draws this surface.
        var style: BrandShapeStyle {
            switch self {
            case .surface: .surface
            case .secondarySurface: .secondarySurface
            case .tertiarySurface: .tertiarySurface
            case .groupedSurface: .groupedSurface
            case .secondaryGroupedSurface: .secondaryGroupedSurface
            case .tertiaryGroupedSurface: .tertiaryGroupedSurface
            }
        }
    }

    /// Holds the image that a render hands back.
    private final class Capture {
        /// The image, or `nil` until the render finishes.
        var image: UIImage?
    }

    /// A made-up person whose initials are two different letters.
    private static let name = PersonNameComponents(givenName: "Ada", familyName: "Archer")

    /// The side of the avatar in points.
    private static let diameter = CGFloat(AvatarSize.xLarge)

    /// How far below the avatar's top edge the fill is read, clear of the letters and the outline.
    private static let fillDepth: CGFloat = 12

    /// The side in points of the square that holds the letters and nothing else.
    private static let letterBoxSide: CGFloat = 40

    /// The contrast ratio of two identical colors, which a blank render produces.
    private static let identicalRatio: Float = 1

    /// The point on the vertical center line where the fill is read.
    private static var fillPoint: CGPoint {
        CGPoint(x: diameter / 2, y: fillDepth)
    }

    /// The square at the center of the avatar that holds the letters and not the outline.
    private static var letterBox: CGRect {
        let origin = (diameter - letterBoxSide) / 2
        return CGRect(x: origin, y: origin, width: letterBoxSide, height: letterBoxSide)
    }

    /// Checks the letters reach the text floor in every brand, appearance and surface.
    ///
    /// - Throws: When a render fails or its pixels cannot be read.
    @Test
    func whenInitialsAreDrawnOnEverySurface_shouldReachTheTextFloor() throws {
        for brand in Brand.allCases {
            for appearance in SystemAppearance.allCases {
                for surface in Surface.allCases {
                    try expectFloor(brand: brand, appearance: appearance, surface: surface)
                }
            }
        }
    }

    /// Checks Increase Contrast never lowers the letters' ratio, in every brand and surface.
    ///
    /// - Throws: When a render fails or its pixels cannot be read.
    @Test
    func whenIncreaseContrastIsOn_shouldNotLowerTheLettersRatio() throws {
        for brand in Brand.allCases {
            for appearance in SystemAppearance.allCases {
                for surface in Surface.allCases {
                    try expectNotLowered(brand: brand, appearance: appearance, surface: surface)
                }
            }
        }
    }

    /// Records a failure when Increase Contrast lowers the letters' ratio.
    ///
    /// An appearance without Increase Contrast has nothing to compare with, so it passes.
    ///
    /// - Parameters:
    ///   - brand: The brand whose surfaces the avatar sits on.
    ///   - appearance: The appearance to draw under.
    ///   - surface: The surface the avatar sits on.
    /// - Throws: When a render fails or its pixels cannot be read.
    private func expectNotLowered(brand: Brand, appearance: SystemAppearance, surface: Surface) throws {
        guard let standard = appearance.withoutIncreasedContrast else { return }
        let increased = try Self.lettersRatio(brand: brand, appearance: appearance, surface: surface)
        let normal = try Self.lettersRatio(brand: brand, appearance: standard, surface: surface)
        let shown = "\(WCAG.text(of: increased)) is below \(WCAG.text(of: normal)) in \(standard.name)"
        #expect(increased >= normal, "\(brand) \(surface) \(appearance.name): \(shown)")
    }

    /// Records a failure when the letters fall below the text floor.
    ///
    /// - Parameters:
    ///   - brand: The brand whose surfaces the avatar sits on.
    ///   - appearance: The appearance to draw under.
    ///   - surface: The surface the avatar sits on.
    /// - Throws: When a render fails or its pixels cannot be read.
    private func expectFloor(brand: Brand, appearance: SystemAppearance, surface: Surface) throws {
        let ratio = try Self.lettersRatio(brand: brand, appearance: appearance, surface: surface)
        let shown = "\(WCAG.text(of: ratio)), floor \(WCAG.text(of: WCAG.textFloor))"
        #expect(ratio >= WCAG.textFloor, "\(brand) \(surface) \(appearance.name): \(shown)")
    }

    /// Returns the strongest contrast between any letter pixel and the avatar's fill.
    ///
    /// - Parameters:
    ///   - brand: The brand whose surfaces the avatar sits on.
    ///   - appearance: The appearance to draw under.
    ///   - surface: The surface the avatar sits on.
    /// - Returns: The ratio, where 1 means the letters cannot be told from the fill.
    /// - Throws: When a render fails or its pixels cannot be read.
    /// - Complexity: O(*n*), where *n* is the number of pixels in the render.
    private static func lettersRatio(brand: Brand, appearance: SystemAppearance, surface: Surface) throws -> Float {
        let image = try render(brand: brand, appearance: appearance, surface: surface)
        let pixels = try Pixels(of: #require(image.cgImage), scale: image.scale)
        // The fill is translucent, so its real color depends on the surface behind it.
        let fill = pixels.color(at: fillPoint)
        return pixels.colors(in: letterBox)
            .map { WCAG.ratio(between: $0, and: fill) }
            .reduce(identicalRatio, max)
    }

    /// Draws an avatar with initials on a surface and returns the image.
    ///
    /// - Parameters:
    ///   - brand: The brand whose surfaces the avatar sits on.
    ///   - appearance: The appearance to draw under.
    ///   - surface: The surface the avatar sits on.
    /// - Returns: An image of the avatar, as the system draws it under the appearance.
    /// - Throws: When the render hands back no image.
    private static func render(brand: Brand, appearance: SystemAppearance, surface: Surface) throws -> UIImage {
        let view = Avatar(url: nil, size: AvatarSize.xLarge, fallback: .initials(name))
            .background(surface.style)
            .environment(\.brand, brand)
            .fixedSize()
        let capture = Capture()
        Snapshotting<AnyView, UIImage>.image(traits: appearance.traits)
            .snapshot(AnyView(view))
            .run { capture.image = $0 }
        return try #require(capture.image)
    }
}
#endif
