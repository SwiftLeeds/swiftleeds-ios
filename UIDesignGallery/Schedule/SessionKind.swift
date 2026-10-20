import SwiftUI

/// The kind of a session, which sets its name, its symbol and its colors.
enum SessionKind: Equatable, Hashable, Sendable {
    /// A full-length talk.
    case talk

    /// A short talk.
    case lightningTalk

    /// A hands-on session where people work along.
    case workshop

    /// A session that people join and leave as they please.
    case dropIn

    /// A saturation and a brightness, which with a hue make one color.
    private struct Shade {
        /// How vivid the color is, from 0 to 1.
        let saturation: Double

        /// How light the color is, from 0 to 1.
        let brightness: Double
    }

    /// The top of the art in light mode, which is pale.
    private static let lightArtTop = Shade(saturation: 0.45, brightness: 0.95)

    /// The foot of the art in light mode.
    private static let lightArtFoot = Shade(saturation: 0.6, brightness: 0.8)

    /// The top of the art in dark mode.
    private static let darkArtTop = Shade(saturation: 0.65, brightness: 0.75)

    /// The foot of the art in dark mode.
    private static let darkArtFoot = Shade(saturation: 0.8, brightness: 0.5)

    /// How bright the tint is in light mode, dark enough for the hero's greyest
    /// text, white at 70 percent, to reach 4.5 to 1.
    private static let lightTintBrightness = 0.3

    /// How bright the tint is in dark mode.
    private static let darkTintBrightness = 0.34

    /// How much of its brightness the tint keeps when a person asks for more
    /// contrast.
    private static let increasedContrastKeep = 0.85

    /// What people call the kind.
    var displayName: String {
        switch self {
        case .talk: "Talk"
        case .lightningTalk: "Lightning talk"
        case .workshop: "Workshop"
        case .dropIn: "Drop-in"
        }
    }

    /// The name of the kind's SF Symbol.
    var symbol: String {
        // A bare name, because `Icon` names no symbol for a kind and `UIDesign` is not edited on
        // this branch.
        switch self {
        case .talk: "mic.fill"
        case .lightningTalk: "bolt.fill"
        case .workshop: "hammer.fill"
        case .dropIn: "person.2.fill"
        }
    }

    /// Where the kind sits on the color wheel, from 0 to 1.
    ///
    /// None of these is orange, so the palette's orange never sits behind
    /// text.
    private var hue: Double {
        switch self {
        case .talk: 0.6
        case .lightningTalk: 0.76
        case .workshop: 0.47
        case .dropIn: 0.92
        }
    }

    /// Returns the kind's tint, the art's foot color darkened, which takes
    /// white text in both schemes.
    ///
    /// - Parameters:
    ///   - scheme: The color scheme the tint is for.
    ///   - contrast: Whether the tint is for more contrast, which makes it
    ///     darker still.
    /// - Returns: The tint, a color that takes white text.
    func tint(in scheme: ColorScheme, contrast: ColorSchemeContrast = .standard) -> Color {
        let isDark = scheme == .dark
        let foot = isDark ? Self.darkArtFoot : Self.lightArtFoot
        let brightness = isDark ? Self.darkTintBrightness : Self.lightTintBrightness
        let keep = contrast == .increased ? Self.increasedContrastKeep : 1
        return color(Shade(saturation: foot.saturation, brightness: brightness * keep))
    }

    /// Returns the colors the kind's art runs between, top to bottom.
    ///
    /// - Parameter scheme: The color scheme the art is for.
    /// - Returns: The top color and the foot color, in that order.
    func artColors(in scheme: ColorScheme) -> [Color] {
        if scheme == .dark {
            [color(Self.darkArtTop), color(Self.darkArtFoot)]
        } else {
            [color(Self.lightArtTop), color(Self.lightArtFoot)]
        }
    }

    /// Returns the kind's hue in the given shade.
    ///
    /// - Parameter shade: The saturation and brightness to give the hue.
    /// - Returns: The kind's hue at the shade.
    private func color(_ shade: Shade) -> Color {
        Color(hue: hue, saturation: shade.saturation, brightness: shade.brightness)
    }
}
