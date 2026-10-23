import SwiftUI

/// A named hue with a tonal ramp of raw colors, from darkest to lightest.
package enum Hue: CaseIterable, Equatable, Hashable, Sendable {
    /// A step of perceived lightness, from 5 (near black) to 95 (near white).
    package enum Tone: CaseIterable, Equatable, Hashable, Sendable {
        /// Lightness 5 of 100.
        case t5  // swiftlint:disable:this identifier_name - named by its tone number, like t10 to t95
        /// Lightness 10 of 100.
        case t10
        /// Lightness 15 of 100.
        case t15
        /// Lightness 20 of 100.
        case t20
        /// Lightness 25 of 100.
        case t25
        /// Lightness 30 of 100.
        case t30
        /// Lightness 35 of 100.
        case t35
        /// Lightness 40 of 100.
        case t40
        /// Lightness 45 of 100.
        case t45
        /// Lightness 50 of 100.
        case t50
        /// Lightness 55 of 100.
        case t55
        /// Lightness 60 of 100.
        case t60
        /// Lightness 65 of 100.
        case t65
        /// Lightness 70 of 100.
        case t70
        /// Lightness 75 of 100.
        case t75
        /// Lightness 80 of 100.
        case t80
        /// Lightness 85 of 100.
        case t85
        /// Lightness 90 of 100.
        case t90
        /// Lightness 95 of 100.
        case t95
    }

    /// The hue for errors.
    case red
    /// The hue for success.
    case green
    /// The hue for warnings.
    case amber
    /// The hue for information, talks and speakers.
    case blue
    /// The hue for workshops.
    case teal
    /// The hue for lightning talks and staff.
    case violet
    /// The hue for drop-in sessions and hosts.
    case raspberry
    /// Grays with no hue.
    case neutral
    /// The hue for sponsors.
    case bronze
}
