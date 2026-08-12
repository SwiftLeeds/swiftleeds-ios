#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
import AuthenticationFeature
import SwiftUI
import Testing

@testable import AuthenticationUI

@MainActor
@Suite(.enabled(if: ProcessInfo.processInfo.environment["RENDER_SNAPSHOTS"] != nil))
struct ComponentSnapshotTests {
    @Test func renderProminentNameplates() throws {
        try render("nameplate-prominent") {
            samples
        }
    }

    @Test func renderCompactNameplates() throws {
        try render("nameplate-compact") {
            samples.nameplateStyle(.compact)
        }
    }

    @Test func renderRedactedNameplate() throws {
        try render("nameplate-redacted") {
            Nameplate(
                Text(verbatim: "Ada Lovelace"),
                detail: Text(verbatim: "ada@example.com")
            ) {
                personAvatar
            }
            .redacted(reason: .placeholder)
        }
    }

    @Test func renderPlaceholder() throws {
        try render("nameplate-placeholder") {
            NameplatePlaceholder()
        }
    }

    @Test func renderMultiLineDetail() throws {
        try render("nameplate-multiline-detail") {
            Nameplate {
                Text(verbatim: "Ada Lovelace")
            } detail: {
                Text(verbatim: "ada@example.com")
                Text(verbatim: "ABCD-1")
            } icon: {
                initialsAvatar
            }
        }
    }

    @Test func renderNarrowWidth() throws {
        try render("nameplate-narrow", width: 220) {
            Nameplate(
                Text(verbatim: "Augusta Ada King-Noel"),
                detail: Text(verbatim: "ada.lovelace@example.com")
            ) {
                initialsAvatar
            }
        }
    }

    @Test func renderAvatars() throws {
        try render("avatars") {
            HStack(spacing: 16) {
                initialsAvatar
                    .font(.largeTitle.weight(.semibold))
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 88, height: 88)

                initialsAvatar
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 56, height: 56)

                personAvatar
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 56, height: 56)

                personAvatar
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 40, height: 40)
            }
        }
    }

    @Test func renderAvatarStyles() throws {
        try render("avatar-styles") {
            VStack(alignment: .leading, spacing: 20) {
                avatarRow
                avatarRow.avatarStyle(.rounded)
                avatarRow.avatarStyle(.rounded(cornerRadius: 4))
            }
        }
    }

    @Test func renderProfileCardStates() throws {
        try render("profile-card-failed") {
            ProfileCardContent(state: .failed, retry: {}, signOut: {})
        }

        try render("profile-card-failed-narrow", width: 200) {
            ProfileCardContent(state: .failed, retry: {}, signOut: {})
        }

        try render("profile-card-failed-tiny", width: 130) {
            ProfileCardContent(state: .failed, retry: {}, signOut: {})
        }

        try render("profile-card-loaded") {
            ProfileCardContent(state: .loaded(.preview), retry: {}, signOut: {})
        }
    }

    private var avatarRow: some View {
        HStack(spacing: 16) {
            initialsAvatar
                .frame(width: 56, height: 56)

            personAvatar
                .frame(width: 56, height: 56)
        }
        .font(.title2.weight(.semibold))
        .foregroundStyle(Color.accentColor)
    }

    private var initialsAvatar: some View {
        Avatar(url: nil) {
            Text(verbatim: "AL")
        }
    }

    private var personAvatar: some View {
        Avatar(url: nil) {
            Image(systemName: "person")
        }
    }

    private var samples: some View {
        VStack(alignment: .leading, spacing: 16) {
            Nameplate(
                Text(verbatim: "Ada Lovelace"),
                detail: Text(verbatim: "ada@example.com")
            ) {
                initialsAvatar
            }

            Divider()

            Nameplate(Text("Sign in"), role: .unresolved) {
                personAvatar
            }

            Divider()

            Nameplate(Text(verbatim: "Ada Lovelace")) {
                initialsAvatar
            }
        }
    }
}

private enum SnapshotError: Error {
    case missingOutputDirectory
    case renderFailed(String)
}

@MainActor
private extension ComponentSnapshotTests {
    static var outputDirectory: URL {
        get throws {
            guard let path = ProcessInfo.processInfo.environment["SNAPSHOT_DIR"] else {
                throw SnapshotError.missingOutputDirectory
            }
            let url = URL(fileURLWithPath: path, isDirectory: true)
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            return url
        }
    }

    func render<V: View>(_ name: String, width: CGFloat = 360, @ViewBuilder _ content: () -> V) throws {
        let directory = try Self.outputDirectory
        let view = content()

        for (suffix, scheme) in [("light", ColorScheme.light), ("dark", ColorScheme.dark)] {
            let renderer = ImageRenderer(
                content: view
                    .environment(\.colorScheme, scheme)
                    .frame(width: width, alignment: .leading)
                    .padding(16)
                    .background(scheme == .dark ? Color.black : Color.white)
            )
            renderer.scale = 2

            #if canImport(UIKit)
            guard let png = renderer.uiImage?.pngData() else {
                throw SnapshotError.renderFailed(name)
            }
            #else
            guard let image = renderer.nsImage,
                  let tiff = image.tiffRepresentation,
                  let representation = NSBitmapImageRep(data: tiff),
                  let png = representation.representation(using: .png, properties: [:])
            else {
                throw SnapshotError.renderFailed(name)
            }
            #endif

            try png.write(to: directory.appendingPathComponent("\(name)-\(suffix).png"))
        }
    }
}
