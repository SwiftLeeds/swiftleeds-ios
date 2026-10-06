/// An icon a person can give the app on their Home Screen.
///
/// Every field is display text rather than a domain value, for the reason
/// `SampleSession` gives.
enum SampleAppIcon: String, CaseIterable, Identifiable {
    /// The icon the app ships with.
    case classic

    /// The dark icon, for a dark Home Screen.
    case night

    /// The icon the KotlinLeeds build ships with.
    case kotlinLeeds

    /// Tells one sample icon from another.
    var id: String { rawValue }

    /// What the row calls it.
    var title: String {
        switch self {
        case .classic: "Classic"
        case .night: "Night"
        case .kotlinLeeds: "KotlinLeeds"
        }
    }

    /// The SF Symbol the swatch draws.
    ///
    /// Each option carries a different glyph, so the three still tell
    /// themselves apart in greyscale and under a widget's accented rendering.
    var symbol: String {
        switch self {
        case .classic: "chevron.left.forwardslash.chevron.right"
        case .night: "moon.stars.fill"
        case .kotlinLeeds: "triangle.fill"
        }
    }
}
