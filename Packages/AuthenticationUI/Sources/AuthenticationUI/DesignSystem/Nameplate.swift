import SwiftUI

package struct Nameplate<Title: View, Detail: View, Icon: View>: View {
    @Environment(\.nameplateStyle) private var style

    private let role: NameplateRole
    private let title: Title
    private let detail: Detail
    private let icon: Icon

    package init(
        role: NameplateRole = .standard,
        @ViewBuilder title: () -> Title,
        @ViewBuilder detail: () -> Detail,
        @ViewBuilder icon: () -> Icon
    ) {
        self.role = role
        self.title = title()
        self.detail = detail()
        self.icon = icon()
    }

    package var body: some View {
        style.makeBody(
            NameplateStyleConfiguration(
                title: NameplateStyleConfiguration.Title(base: AnyView(title)),
                detail: NameplateStyleConfiguration.Detail(base: AnyView(detail)),
                icon: NameplateStyleConfiguration.Icon(base: AnyView(icon.accessibilityHidden(true))),
                role: role
            )
        )
        .accessibilityElement(children: .combine)
    }
}

package extension Nameplate where Title == Text, Detail == Text {
    init(
        _ title: Text,
        detail: Text,
        role: NameplateRole = .standard,
        @ViewBuilder icon: () -> Icon
    ) {
        self.init(role: role, title: { title }, detail: { detail }, icon: icon)
    }
}

package extension Nameplate where Title == Text, Detail == EmptyView {
    init(
        _ title: Text,
        role: NameplateRole = .standard,
        @ViewBuilder icon: () -> Icon
    ) {
        self.init(role: role, title: { title }, detail: { EmptyView() }, icon: icon)
    }
}

private let previewAvatarURL = URL(string: "https://example.com/missing.png")

#Preview("Prominent") {
    NavigationStack {
        List {
            Nameplate(Text(verbatim: "Ada Lovelace"), detail: Text(verbatim: "ada@example.com")) {
                Avatar(url: previewAvatarURL) {
                    Text(verbatim: "AL").font(.title2.weight(.semibold))
                }
            }

            Nameplate(Text("Sign In"), role: .unresolved) {
                Avatar(url: nil) {
                    Image(systemName: "person").font(.title)
                }
            }

            Nameplate(Text(verbatim: "Ada Lovelace")) {
                Avatar(url: previewAvatarURL) {
                    Text(verbatim: "AL").font(.title2.weight(.semibold))
                }
            }
        }
    }
}

#Preview("Compact") {
    NavigationStack {
        List {
            Nameplate(Text(verbatim: "Ada Lovelace"), detail: Text(verbatim: "ada@example.com")) {
                Avatar(url: previewAvatarURL) {
                    Text(verbatim: "AL").font(.subheadline.weight(.semibold))
                }
            }

            Nameplate(Text("Sign In"), role: .unresolved) {
                Avatar(url: nil) {
                    Image(systemName: "person")
                }
            }
        }
        .nameplateStyle(.compact)
    }
}

#Preview("Multi-line detail") {
    NavigationStack {
        List {
            Nameplate {
                Text(verbatim: "Ada Lovelace")
            } detail: {
                Text(verbatim: "ada@example.com")
                Text(verbatim: "ABCD-1")
            } icon: {
                Avatar(url: previewAvatarURL) {
                    Text(verbatim: "AL").font(.title2.weight(.semibold))
                }
            }
        }
    }
}
