import AboutFeature
import CachedAsyncImage
import DesignKit
import SharedAssets
import SwiftUI

struct TeamMemberView: View {
    let member: TeamMember

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [.accentColor.opacity(0.8), .accentColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)

                CachedAsyncImage(url: member.photoURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                } placeholder: {
                    Text(initials)
                        .font(.title.weight(.semibold))
                        .foregroundColor(.white)
                }
            }
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)

            VStack(spacing: 6) {
                Text(member.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                Text(member.role ?? " ")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(minHeight: 32)
                    .opacity(member.role != nil ? 1.0 : 0.0)
            }

            HStack(spacing: 16) {
                ForEach(member.links, id: \.self) { link in
                    Button {
                        UIApplication.shared.open(link.url)
                    } label: {
                        Image(systemName: link.symbolName)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.accentColor)
                    }
                    .accessibilityLabel(link.accessibilityLabel(for: member.name))
                }
            }
            .frame(minHeight: 32)
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .padding(Padding.cell)
        .background(
            Color.cellBackground,
            in: RoundedRectangle(cornerRadius: Constants.cellRadius)
        )
    }

    private var initials: String {
        let components = member.name.components(separatedBy: " ")
        let firstInitial = components.first?.first?.uppercased() ?? ""
        let lastInitial = components.count > 1 ? (components.last?.first?.uppercased() ?? "") : ""
        return firstInitial + lastInitial
    }
}

private extension SocialLink {
    var url: URL {
        switch self {
        case .linkedIn(let url):
            url
        case .twitter(let url):
            url
        case .slack(let url):
            url
        }
    }

    var symbolName: String {
        switch self {
        case .linkedIn:
            "person.crop.rectangle"
        case .twitter:
            "at"
        case .slack:
            "bubble.left.and.bubble.right"
        }
    }

    func accessibilityLabel(for name: String) -> String {
        switch self {
        case .linkedIn:
            "LinkedIn profile for \(name)"
        case .twitter:
            "Twitter profile for \(name)"
        case .slack:
            "Message \(name) on Slack"
        }
    }
}

struct TeamMemberView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            preview(
                member(
                    "Member One",
                    role: "Organizer",
                    photo: "/img/team/member-one.jpg",
                    linkedIn: "https://linkedin.example.com/member-one",
                    twitter: "https://twitter.example.com/member-one",
                    slack: "https://slack.example.com/member-one"
                ),
                named: "With Role & All Links"
            )

            preview(
                member(
                    "Member Two",
                    role: nil,
                    photo: "/img/team/member-two.jpg",
                    linkedIn: "https://linkedin.example.com/member-two",
                    slack: "https://slack.example.com/member-two"
                ),
                named: "No Role & Partial Links"
            )

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(gridMembers) { member in
                    TeamMemberView(member: member)
                }
            }
            .padding()
            .previewDisplayName("Grid Layout")
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }

    private static var gridMembers: [TeamMember] {
        [
            member(
                "Member Three",
                role: "Production",
                photo: "/img/team/member-three.jpg",
                linkedIn: "https://linkedin.example.com/member-three",
                twitter: "https://twitter.example.com/member-three"
            ),
            member(
                "Member Four",
                role: "Camera",
                photo: "/img/team/member-four.jpg",
                twitter: "https://twitter.example.com/member-four",
                slack: "https://slack.example.com/member-four"
            ),
        ]
        .compactMap(\.self)
    }

    @ViewBuilder
    private static func preview(_ member: TeamMember?, named displayName: String) -> some View {
        if let member {
            TeamMemberView(member: member)
                .previewDisplayName(displayName)
        } else {
            Text(verbatim: "The preview's team member could not be built.")
        }
    }

    private static func member(
        _ name: String,
        role: String?,
        photo: String,
        linkedIn: String? = nil,
        twitter: String? = nil,
        slack: String? = nil
    ) -> TeamMember? {
        guard let photoURL = URL(string: "https://\(ConferenceConfig.apiHost)\(photo)") else { return nil }
        let links = [
            linkedIn.flatMap { URL(string: $0) }.map { SocialLink.linkedIn($0) },
            twitter.flatMap { URL(string: $0) }.map { SocialLink.twitter($0) },
            slack.flatMap { URL(string: $0) }.map { SocialLink.slack($0) },
        ]
        return TeamMember(
            id: TeamMemberID(name),
            name: name,
            role: role,
            photoURL: photoURL,
            links: links.compactMap(\.self)
        )
    }
}
