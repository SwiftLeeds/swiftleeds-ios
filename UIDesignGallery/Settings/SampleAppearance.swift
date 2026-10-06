/// How light or dark a person asks the app to be.
///
/// This carries a title and a symbol of its own, which is why it exists rather
/// than an optional `ColorScheme`.
enum SampleAppearance: String, CaseIterable, Identifiable {
    /// Whatever the system is set to.
    case automatic

    /// Light, whatever the system is set to.
    case light

    /// Dark, whatever the system is set to.
    case dark

    /// Tells one sample appearance from another.
    var id: String { rawValue }

    /// What the row calls it.
    var title: String {
        switch self {
        case .automatic: "Automatic"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    /// The SF Symbol that stands for it.
    var symbol: String {
        switch self {
        case .automatic: "circle.lefthalf.filled"
        case .light: "sun.max"
        case .dark: "moon"
        }
    }
}
