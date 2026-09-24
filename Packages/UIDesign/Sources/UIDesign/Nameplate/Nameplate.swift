import SwiftUI

/// A subject, named beside its picture.
///
/// It draws an icon, a title and one more line about the subject. The icon is
/// usually an ``Avatar``, and a speaker, a guest and a sponsor are all
/// subjects.
///
/// ```swift
/// Nameplate(speaker.name, detail: speaker.company) {
///     Avatar(url: speaker.photoURL, fallback: .initials(speaker.nameComponents))
/// }
/// ```
///
/// A string literal is localized and a `String` variable is not, so a name
/// that came from a server stays as the server wrote it. When one line needs
/// localizing and the other does not, pass two `Text` values through
/// ``init(title:detail:icon:)``.
///
/// The icon keeps the size the caller gave it. Use ``AvatarSize/medium`` in a
/// row and ``AvatarSize/large`` in a heading.
///
/// With either built-in style the icon moves above the text at the
/// accessibility text sizes, so a row becomes a stack.
///
/// VoiceOver reads the whole nameplate as one element, so it announces the
/// subject rather than each line in turn.
///
/// A nameplate is not a control. Give a tappable one a target of at least 44
/// points.
public struct Nameplate<Title: View, Detail: View, Icon: View>: View {
    /// How this nameplate draws.
    @Environment(\.nameplateStyle) private var style

    /// What the subject is called.
    private let title: Title

    /// One more line about the subject.
    private let detail: Detail

    /// The picture of the subject.
    private let icon: Icon

    /// Creates a nameplate from three views.
    ///
    /// - Parameters:
    ///   - title: What the subject is called.
    ///   - detail: One more line about the subject.
    ///   - icon: The picture of the subject.
    public init(
        @ViewBuilder title: () -> Title,
        @ViewBuilder detail: () -> Detail,
        @ViewBuilder icon: () -> Icon
    ) {
        self.title = title()
        self.detail = detail()
        self.icon = icon()
    }

    public var body: some View {
        AnyView(style.makeBody(configuration: configuration))
            .accessibilityElement(children: .combine)
    }

    /// The views handed to the style.
    private var configuration: NameplateStyleConfiguration {
        NameplateStyleConfiguration(title: title, detail: detail, icon: icon)
    }
}

public extension Nameplate where Title == Text, Detail == Text {
    /// Creates a nameplate whose title and detail are localized.
    ///
    /// - Parameters:
    ///   - titleKey: The key for what the subject is called.
    ///   - detail: The key for one more line about the subject.
    ///   - icon: The picture of the subject.
    init(
        _ titleKey: LocalizedStringKey,
        detail: LocalizedStringKey,
        @ViewBuilder icon: () -> Icon
    ) {
        self.init(title: { Text(titleKey) }, detail: { Text(detail) }, icon: icon)
    }

    /// Creates a nameplate that shows exactly the text it is given.
    ///
    /// Nothing here is localized, so this is the initializer for text that
    /// came from a server or from a person.
    ///
    /// - Parameters:
    ///   - title: What the subject is called.
    ///   - detail: One more line about the subject.
    ///   - icon: The picture of the subject.
    init(
        _ title: some StringProtocol,
        detail: some StringProtocol,
        @ViewBuilder icon: () -> Icon
    ) {
        self.init(title: { Text(title) }, detail: { Text(detail) }, icon: icon)
    }
}

public extension Nameplate where Title == Text, Detail == EmptyView {
    /// Creates a nameplate whose localized title stands on its own.
    ///
    /// - Parameters:
    ///   - titleKey: The key for what the subject is called.
    ///   - icon: The picture of the subject.
    init(_ titleKey: LocalizedStringKey, @ViewBuilder icon: () -> Icon) {
        self.init(title: { Text(titleKey) }, detail: { EmptyView() }, icon: icon)
    }

    /// Creates a nameplate whose title stands on its own, shown as given.
    ///
    /// - Parameters:
    ///   - title: What the subject is called.
    ///   - icon: The picture of the subject.
    init(_ title: some StringProtocol, @ViewBuilder icon: () -> Icon) {
        self.init(title: { Text(title) }, detail: { EmptyView() }, icon: icon)
    }
}

/// A made-up name, held in a `let` so it binds to the initializer that does
/// not localize.
private let previewName = "Ada Archer"

/// What the preview's subject does, shown as the detail line.
private let previewCompany = "Northern Software"

/// The preview name in parts, so the avatar can abbreviate it.
private let previewNameComponents = PersonNameComponents(
    givenName: "Ada",
    familyName: "Archer"
)

#Preview("Row") {
    VStack(spacing: .large) {
        Nameplate(previewName, detail: previewCompany) {
            Avatar(url: nil, fallback: .initials(previewNameComponents))
        }

        Nameplate(previewName) {
            Avatar(url: nil, fallback: .initials(previewNameComponents))
        }

        Nameplate("Sign In") {
            Avatar(url: nil)
        }
    }
    .padding(.large)
}

#Preview("Heading") {
    Nameplate(previewName, detail: previewCompany) {
        Avatar(
            url: nil,
            size: .large,
            status: AvatarStatus("Checked in"),
            fallback: .initials(previewNameComponents)
        )
    }
    .nameplateStyle(.prominent)
    .padding(.large)
}
