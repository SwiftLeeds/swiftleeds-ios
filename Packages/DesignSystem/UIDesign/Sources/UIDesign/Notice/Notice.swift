import SFSafeSymbols
import SwiftUI

/// A view that reports a condition and offers one action to resolve it.
///
/// A notice sits in a list section, such as "You're offline" with a "Try Again" button.
/// It draws no surface and adds no padding, so the section supplies both.
///
/// You create a notice with a title, an icon, a description and an action.
///
/// ```swift
/// List {
///     Section {
///         Notice(
///             "You're offline",
///             icon: Icon(.wifiSlash),
///             description: Text("The schedule shows what was saved. It updates when you reconnect."),
///         ) {
///             Button("Try Again") { reload() }
///                 .buttonStyle(.borderless)
///         }
///     }
/// }
/// ```
///
/// In a `List` row, give the button the `.borderless` style. A button with the automatic style
/// makes the whole row its target, so a tap on the title or the description runs the action.
/// The notice never sets a button style itself. It grows the borderless button's tappable area
/// to the minimum target size.
///
/// A notice does not announce itself when it appears. The screen that changes the condition
/// announces it, using the same localized title the notice shows.
///
/// ```swift
/// private let offlineTitle: LocalizedStringResource = "You're offline"
///
/// Notice(offlineTitle, icon: Icon(.wifiSlash), description: Text("...")) {
///     Button("Try Again") { reload() }.buttonStyle(.borderless)
/// }
/// .onChange(of: isOffline) { _, isOffline in
///     guard isOffline else { return }
///     AccessibilityNotification.Announcement(String(localized: offlineTitle)).post()
/// }
/// ```
///
/// The announcement comes from the `Accessibility` framework.
///
/// VoiceOver reads the title and the description as one element, then the action as a button.
/// It skips the icon, so the title must say what the icon shows.
///
/// | Part | Kind | Text size | VoiceOver |
/// | --- | --- | --- | --- |
/// | Title | Essential | Grows | Read, with the description |
/// | Description | Essential | Grows | Read, with the title |
/// | Icon | Decoration | Keeps its size | Skipped |
/// | Action | Essential | Grows | Its own button |
public struct Notice<Title: View, Icon: View, Description: View, Actions: View>: View {
    /// A view that draws a notice in a given style.
    ///
    /// It stores the style, so SwiftUI installs the style's property wrappers.
    private struct ResolvedNoticeStyle<Style: NoticeStyle>: View {
        /// The style that draws the notice.
        let style: Style

        /// The properties of the notice.
        let configuration: NoticeStyleConfiguration

        var body: some View {
            style.makeBody(configuration: configuration)
        }
    }

    /// The current notice style.
    @Environment(\.noticeStyle) private var style

    /// The title of the notice.
    private let title: Title

    /// The icon of the notice.
    private let icon: Icon

    /// The description of the notice.
    private let description: Description

    /// The actions of the notice.
    private let actions: Actions

    /// Creates a notice with a custom title, icon, description and actions.
    ///
    /// - Parameters:
    ///   - title: A content builder that creates the notice's title.
    ///   - icon: A content builder that creates the notice's icon.
    ///   - description: A content builder that creates the notice's description. The default is
    ///     an empty view.
    ///   - actions: A content builder that creates the notice's actions. The default is an empty
    ///     view.
    public init(
        @ViewBuilder title: () -> Title,
        @ViewBuilder icon: () -> Icon,
        @ViewBuilder description: () -> Description = { EmptyView() },
        @ViewBuilder actions: () -> Actions = { EmptyView() },
    ) {
        self.title = title()
        self.icon = icon()
        self.description = description()
        self.actions = actions()
    }

    public var body: some View {
        AnyView(resolved(in: style))
    }

    /// The properties handed to the notice style.
    private var configuration: NoticeStyleConfiguration {
        NoticeStyleConfiguration(title: title, icon: icon, description: description, actions: actions)
    }

    /// Returns a view that draws the notice in the given style.
    ///
    /// - Parameter style: The style to draw the notice in.
    /// - Returns: A view that draws the notice in `style`.
    private func resolved(in style: some NoticeStyle) -> some View {
        ResolvedNoticeStyle(style: style, configuration: configuration)
    }
}

#Preview("Offline") {
    List {
        Section {
            Notice(
                "You're offline",
                icon: Icon(.wifiSlash),
                description: Text("The schedule shows what was saved. It updates when you reconnect."),
            ) {
                Button("Try Again") {}
                    .buttonStyle(.borderless)
            }
        }
    }
}

#Preview("Notifications are off") {
    List {
        Section {
            Notice(
                "Notifications are off",
                icon: Icon(.bellSlash),
                description: Text("Turn them on in Settings to hear when a session moves."),
            ) {
                Button("Open Settings") {}
                    .buttonStyle(.borderless)
            }
        }
    }
}
