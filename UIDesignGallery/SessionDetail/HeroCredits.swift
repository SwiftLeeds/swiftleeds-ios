import SwiftUI

/// A view that credits a session's speakers in one line of text.
///
/// A lead word such as "Led by" comes first, then each speaker's name. A tap on a name shows that
/// speaker.
struct HeroCredits: View {
    /// The kind of session, which sets the lead word.
    private let kind: SessionKind

    /// The speakers to credit, in the order their names read.
    private let speakers: [SamplePerson]

    /// The color of the lead word.
    private let leadColor: Color

    /// The action that shows a person's page.
    private let showPerson: (SamplePerson) -> Void

    /// Whether this person asked for more contrast.
    @Environment(\.colorSchemeContrast) private var contrast

    /// Creates a line that credits a session's speakers.
    ///
    /// - Parameters:
    ///   - kind: The kind of session, which sets the lead word.
    ///   - speakers: The speakers to credit, in the order their names read.
    ///   - leadColor: The color of the lead word, a grey that still reads on the hero.
    ///   - showPerson: The action that shows a person's page. A tap on a name runs it.
    init(
        kind: SessionKind,
        speakers: [SamplePerson],
        leadColor: Color,
        showPerson: @escaping (SamplePerson) -> Void,
    ) {
        self.kind = kind
        self.speakers = speakers
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

    /// The URL scheme that stands for a tap on a speaker's name.
    private static let speakerScheme = "speaker"
}

// MARK: - Credits

extension HeroCredits {
    /// The credits as one line of text, a lead word and then each speaker's name as a link.
    private var creditString: AttributedString {
        var credits = AttributedString("\(kind.creditVerb) ")
        credits.foregroundColor = leadColor
        let last = speakers.count - 1
        for (index, speaker) in speakers.enumerated() {
            var name = AttributedString(index < last ? "\(speaker.name), " : speaker.name)
            name.foregroundColor = nameColor
            name.link = URL(string: "\(Self.speakerScheme)://\(index)")
            credits += name
        }
        return credits
    }

    /// Shows the speaker whose name a tap opened.
    ///
    /// - Parameter url: The link of the name that was tapped.
    /// - Returns: `.handled` for a speaker's link, else `.discarded`.
    private func open(_ url: URL) -> OpenURLAction.Result {
        guard url.scheme == Self.speakerScheme,
            let index = url.host().flatMap(Int.init),
            speakers.indices.contains(index)
        else { return .discarded }
        showPerson(speakers[index])
        return .handled
    }

    /// The color of the names, near white, or fully white for more contrast.
    private var nameColor: Color {
        SessionHero.onHero.opacity(contrast == .increased ? 1 : Self.nameOpacity)
    }
}
