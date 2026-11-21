import Foundation
import SwiftUI

/// A container for grouping avatars that stand for the people of one subject.
///
/// ```swift
/// AvatarGroup {
///     ForEach(session.speakers) { speaker in
///         Avatar(url: speaker.photoURL, size: .small, fallback: .initials(speaker.name))
///     }
/// }
/// ```
///
/// The avatars sit side by side, so every initial stays whole. Give a group
/// avatars of one size. A group draws at its natural width, so a screen that
/// lists groups sets their width to line them up.
///
/// On the Watch a group never sits beside a person's name. Show the group or the
/// names, not both in one row.
///
/// ### Naming a group for VoiceOver
///
/// A group adds no element of its own, and each avatar's status stays an
/// element. To make a group that stands alone one element, label it and mark it
/// as an image.
///
/// ```swift
/// AvatarGroup {
///     ForEach(attendees) { attendee in
///         Avatar(url: attendee.photoURL, size: .small, fallback: .initials(attendee.name))
///     }
/// }
/// .accessibilityElement(children: .ignore)
/// .accessibilityLabel("Ada Archer and 2 others")
/// .accessibilityAddTraits(.isImage)
/// ```
///
/// A label on a group replaces the statuses, so put a status that matters in
/// the label.
///
/// ### Placing a group beside names
///
/// At the accessibility text sizes three avatars take about two fifths of a row.
/// Stack the group above the names then, to give the names more width.
///
/// ```swift
/// @Environment(\.dynamicTypeSize) private var dynamicTypeSize
///
/// var body: some View {
///     let layout =
///         dynamicTypeSize.isAccessibilitySize
///         ? AnyLayout(VStackLayout(alignment: .leading))
///         : AnyLayout(HStackLayout())
///     layout {
///         AvatarGroup { speakerAvatars }
///         Text(session.speakerNames)
///     }
/// }
/// ```
public struct AvatarGroup<Content: View>: View {
    /// A view that draws an avatar group in a given style.
    private struct ResolvedAvatarGroupStyle<Style: AvatarGroupStyle>: View {
        /// The style that draws the group.
        let style: Style

        /// The properties of the avatar group.
        let configuration: AvatarGroupStyleConfiguration

        var body: some View {
            style.makeBody(configuration: configuration)
        }
    }

    /// The current avatar group style.
    @Environment(\.avatarGroupStyle) private var style

    /// The avatars to show.
    private let content: Content

    /// Creates an avatar group with the specified content.
    ///
    /// - Parameter content: A content builder that creates the avatars of this
    ///   group.
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        AnyView(resolved(in: style))
    }

    /// The properties handed to the current avatar group style.
    private var configuration: AvatarGroupStyleConfiguration {
        AvatarGroupStyleConfiguration(content: content, overflow: EmptyView?.none)
    }

    /// Returns a view that draws the group in the given style.
    ///
    /// - Parameter style: The style to draw the group in.
    /// - Returns: A view that draws the group in `style`.
    private func resolved(in style: some AvatarGroupStyle) -> some View {
        ResolvedAvatarGroupStyle(style: style, configuration: configuration)
    }
}

private let previewPeople = [
    PersonNameComponents(givenName: "Ada", familyName: "Archer"),
    PersonNameComponents(givenName: "Blake", familyName: "Brooks"),
    PersonNameComponents(givenName: "Casey", familyName: "Cole"),
]

#Preview("Sizes and statuses") {
    VStack(alignment: .leading, spacing: .lg) {
        AvatarGroup {
            ForEach(previewPeople, id: \.self) { name in
                Avatar(url: nil, size: .small, fallback: .initials(name))
            }
        }

        AvatarGroup {
            Avatar(url: nil, size: .medium, status: AvatarStatus("Checked in"), fallback: .initials(previewPeople[0]))
            Avatar(url: nil, size: .medium, fallback: .initials(previewPeople[1]))
        }

        AvatarGroup {
            ForEach(previewPeople, id: \.self) { name in
                Avatar(url: nil, size: .large, fallback: .initials(name))
            }
        }
        .avatarStyle(.rounded)
    }
    .padding(.lg)
}
