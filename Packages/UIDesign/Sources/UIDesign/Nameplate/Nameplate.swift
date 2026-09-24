import SwiftUI

/// A standard view for identifying a subject, consisting of an icon with a
/// title and a detail.
///
/// A nameplate appears wherever a screen names somebody: a speaker in a list,
/// a guest, a sponsor, or the account a settings screen belongs to.
///
/// You create a nameplate by providing a title, a detail and an icon. The icon
/// is usually an ``Avatar``.
///
/// ```swift
/// Nameplate(speaker.name, detail: speaker.company) {
///     Avatar(url: speaker.photoURL, fallback: .initials(speaker.nameComponents))
/// }
/// ```
///
/// A string literal binds to the initializer that localizes, and a `String`
/// variable binds to the one that does not, so a name that came from a server
/// stays as the server wrote it. To localize one line and not the other, pass
/// two `Text` views to ``init(title:detail:icon:)``.
///
/// The icon keeps the size it is given. Use ``AvatarSize/medium`` in a row and
/// ``AvatarSize/large`` in a heading.
///
/// With either built-in style, the icon moves above the text at the
/// accessibility text sizes, so a row becomes a stack.
///
/// VoiceOver reads a nameplate as a single element, so it announces the
/// subject rather than each line in turn.
///
/// A nameplate is not a control. Give a tappable one a target of at least 44
/// points.
public struct Nameplate<Title: View, Detail: View, Icon: View>: View {
    /// The current nameplate style.
    @Environment(\.nameplateStyle) private var style

    /// A name for the subject.
    private let title: Title

    /// A description of the subject.
    private let detail: Detail

    /// A pictorial representation of the subject.
    private let icon: Icon

    /// Creates a nameplate with a custom title, detail and icon.
    ///
    /// - Parameters:
    ///   - title: A content builder that creates the nameplate's title.
    ///   - detail: A content builder that creates the nameplate's detail.
    ///   - icon: A content builder that creates the nameplate's icon.
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

    /// The properties handed to the current nameplate style.
    private var configuration: NameplateStyleConfiguration {
        NameplateStyleConfiguration(title: title, detail: detail, icon: icon)
    }
}

public extension Nameplate where Title == Text, Detail == Text {
    /// Creates a nameplate with a title and a detail generated from localized
    /// strings.
    ///
    /// - Parameters:
    ///   - titleKey: A title generated from a localized string.
    ///   - detail: A detail generated from a localized string.
    ///   - icon: A content builder that creates the nameplate's icon.
    init(
        _ titleKey: LocalizedStringKey,
        detail: LocalizedStringKey,
        @ViewBuilder icon: () -> Icon
    ) {
        self.init(title: { Text(titleKey) }, detail: { Text(detail) }, icon: icon)
    }

    /// Creates a nameplate with a title and a detail generated from strings.
    ///
    /// Neither string is localized, so this is the initializer for text that
    /// came from a server or from a person.
    ///
    /// - Parameters:
    ///   - title: A string used as the nameplate's title.
    ///   - detail: A string used as the nameplate's detail.
    ///   - icon: A content builder that creates the nameplate's icon.
    init(
        _ title: some StringProtocol,
        detail: some StringProtocol,
        @ViewBuilder icon: () -> Icon
    ) {
        self.init(title: { Text(title) }, detail: { Text(detail) }, icon: icon)
    }
}

public extension Nameplate where Title == Text, Detail == EmptyView {
    /// Creates a nameplate with a title generated from a localized string.
    ///
    /// - Parameters:
    ///   - titleKey: A title generated from a localized string.
    ///   - icon: A content builder that creates the nameplate's icon.
    init(_ titleKey: LocalizedStringKey, @ViewBuilder icon: () -> Icon) {
        self.init(title: { Text(titleKey) }, detail: { EmptyView() }, icon: icon)
    }

    /// Creates a nameplate with a title generated from a string.
    ///
    /// - Parameters:
    ///   - title: A string used as the nameplate's title.
    ///   - icon: A content builder that creates the nameplate's icon.
    init(_ title: some StringProtocol, @ViewBuilder icon: () -> Icon) {
        self.init(title: { Text(title) }, detail: { EmptyView() }, icon: icon)
    }
}

/// A made-up name, held in a variable so it binds to the initializer that does
/// not localize.
private let previewName = "Ada Archer"

/// A made-up company, shown as the preview's detail line.
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
