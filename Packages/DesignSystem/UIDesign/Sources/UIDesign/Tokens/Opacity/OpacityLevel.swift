/// An amount of a color that shows, on a grid of 4 percent.
package struct OpacityLevel: Equatable, Hashable, Sendable {
    /// The number of percent in the whole range.
    fileprivate static let wholePercent: Double = 100

    /// The level, in whole percent.
    fileprivate let percent: Int

    /// Creates a level from a number of percent.
    ///
    /// - Parameter percent: The level, in whole percent.
    private init(percent: Int) {
        self.percent = percent
    }
}

extension OpacityLevel {
    // swiftlint:disable no_magic_numbers - each number here is the value its name defines
    /// Clear: nothing of the color shows.
    package static let percent0 = OpacityLevel(percent: 0)

    /// The level of 4 percent.
    package static let percent4 = OpacityLevel(percent: 4)

    /// The level of 8 percent.
    package static let percent8 = OpacityLevel(percent: 8)

    /// The level of 12 percent.
    package static let percent12 = OpacityLevel(percent: 12)

    /// The level of 16 percent.
    package static let percent16 = OpacityLevel(percent: 16)

    /// The level of 20 percent.
    package static let percent20 = OpacityLevel(percent: 20)

    /// The level of 24 percent.
    package static let percent24 = OpacityLevel(percent: 24)

    /// The level of 28 percent.
    package static let percent28 = OpacityLevel(percent: 28)

    /// The level of 32 percent.
    package static let percent32 = OpacityLevel(percent: 32)

    /// The level of 36 percent.
    package static let percent36 = OpacityLevel(percent: 36)

    /// The level of 40 percent.
    package static let percent40 = OpacityLevel(percent: 40)

    /// The level of 44 percent.
    package static let percent44 = OpacityLevel(percent: 44)

    /// The level of 48 percent.
    package static let percent48 = OpacityLevel(percent: 48)

    /// The level of 52 percent.
    package static let percent52 = OpacityLevel(percent: 52)

    /// The level of 56 percent.
    package static let percent56 = OpacityLevel(percent: 56)

    /// The level of 60 percent.
    package static let percent60 = OpacityLevel(percent: 60)

    /// The level of 64 percent.
    package static let percent64 = OpacityLevel(percent: 64)

    /// The level of 68 percent.
    package static let percent68 = OpacityLevel(percent: 68)

    /// The level of 72 percent.
    package static let percent72 = OpacityLevel(percent: 72)

    /// The level of 76 percent.
    package static let percent76 = OpacityLevel(percent: 76)

    /// The level of 80 percent.
    package static let percent80 = OpacityLevel(percent: 80)

    /// The level of 84 percent.
    package static let percent84 = OpacityLevel(percent: 84)

    /// The level of 88 percent.
    package static let percent88 = OpacityLevel(percent: 88)

    /// The level of 92 percent.
    package static let percent92 = OpacityLevel(percent: 92)

    /// The level of 96 percent.
    package static let percent96 = OpacityLevel(percent: 96)

    /// Opaque: all of the color shows.
    package static let percent100 = OpacityLevel(percent: 100)
    // swiftlint:enable no_magic_numbers
}

extension OpacityLevel: CaseIterable {
    /// Every level, from clear to opaque.
    package static let allCases: [OpacityLevel] = [
        .percent0,
        .percent4,
        .percent8,
        .percent12,
        .percent16,
        .percent20,
        .percent24,
        .percent28,
        .percent32,
        .percent36,
        .percent40,
        .percent44,
        .percent48,
        .percent52,
        .percent56,
        .percent60,
        .percent64,
        .percent68,
        .percent72,
        .percent76,
        .percent80,
        .percent84,
        .percent88,
        .percent92,
        .percent96,
        .percent100,
    ]
}

extension Double {
    /// Creates an amount from an opacity level.
    ///
    /// The amount runs from 0 (clear) to 1 (opaque).
    ///
    /// - Parameter level: The level to read.
    package init(_ level: OpacityLevel) {
        self = Double(level.percent) / OpacityLevel.wholePercent
    }
}
