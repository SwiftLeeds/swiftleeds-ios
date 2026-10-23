import SwiftUI

/// A view that credits the people who give or run a session in one line of text.
///
/// A lead word such as "Led by" comes first, then each credited name. A tap on a name shows that
/// person.
struct HeroCredits: View {
    /// Who gives or runs the session. Its kind sets the lead word.
    private let lineup: SessionLineup

    /// The color of the lead word.
    private let leadColor: Color

    /// The action that shows a person's page.
    private let showPerson: (SamplePerson) -> Void

    /// Whether this person asked for more contrast.
    @Environment(\.colorSchemeContrast) private var contrast

    /// Creates a line that credits the people who give or run a session.
    ///
    /// - Parameters:
    ///   - lineup: Who gives or runs the session. Its kind sets the lead word.
    ///   - leadColor: The color of the lead word, a grey that still reads on the hero.
    ///   - showPerson: The action that shows a person's page. A tap on a name runs it.
    init(
        lineup: SessionLineup,
        leadColor: Color,
        showPerson: @escaping (SamplePerson) -> Void,
    ) {
        self.lineup = lineup
        self.leadColor = leadColor
        self.showPerson = showPerson
    }

    /// The credits in the summary's text style, so their lines match.
    var body: some View {
        Text(creditString)
            .font(.subheadline)
            .tint(nameColor)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .environment(\.openURL, OpenURLAction(handler: open))
    }
}

// MARK: - Constants

extension HeroCredits {
    /// How opaque the names are, against white.
    private static let nameOpacity: Double = 0.92

    /// The URL scheme that stands for a tap on a credited name.
    private static let personScheme = "person"
}

// MARK: - Credits

extension HeroCredits {
    /// The credits as one line of text, a lead word and then each credited name as a link.
    private var creditString: AttributedString {
        var credits = AttributedString("\(lineup.kind.creditVerb) ")
        credits.foregroundColor = leadColor
        let people = lineup.credited
        let last = people.count - 1
        for (index, person) in people.enumerated() {
            var name = AttributedString(index < last ? "\(person.name), " : person.name)
            name.foregroundColor = nameColor
            name.link = URL(string: "\(Self.personScheme)://\(index)")
            credits += name
        }
        return credits
    }

    /// Shows the person whose name a tap opened.
    ///
    /// - Parameter url: The link of the name that was tapped.
    /// - Returns: `.handled` for a credited name's link, else `.discarded`.
    private func open(_ url: URL) -> OpenURLAction.Result {
        let people = lineup.credited
        guard url.scheme == Self.personScheme,
            let index = url.host().flatMap(Int.init),
            people.indices.contains(index)
        else { return .discarded }
        showPerson(people[index])
        return .handled
    }

    /// The color of the names, near white, or fully white for more contrast.
    private var nameColor: Color {
        SessionHero.onHero.opacity(contrast == .increased ? 1 : Self.nameOpacity)
    }
}
