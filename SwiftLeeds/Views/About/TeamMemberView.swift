//
//  TeamMemberView.swift
//  SwiftLeeds
//
//  Created by Muralidharan Kathiresan on 09/09/2025.
//

import SwiftUI
import CachedAsyncImage

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
                
                if let photoURL = member.photoURL, let url = URL(string: photoURL) {
                    CachedAsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    } placeholder: {
                        Text(initials)
                            .font(.title.weight(.semibold))
                            .foregroundColor(.white)
                    }
                } else {
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
                if let linkedInURL = member.linkedInURL {
                    Button(action: { openURL(URL(string: linkedInURL)) }) {
                        Image(systemName: "person.crop.rectangle")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.accentColor)
                    }
                    .accessibilityLabel("LinkedIn profile for \(member.name)")
                }
                
                if let twitterURL = member.twitterURL {
                    Button(action: { openURL(URL(string: twitterURL)) }) {
                        Image(systemName: "at")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.accentColor)
                    }
                    .accessibilityLabel("Twitter profile for \(member.name)")
                }
                
                if let slackURL = member.slackURL {
                    Button(action: { openURL(URL(string: slackURL)) }) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.accentColor)
                    }
                    .accessibilityLabel("Message \(member.name) on Slack")
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
    
    private func openURL(_ url: URL?) {
        guard let url = url else { return }
        UIApplication.shared.open(url)
    }
}

struct TeamMemberView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Team member with role and all social links
            TeamMemberView(member: TeamMember(
                name: "Adam Rush",
                role: "Founder and Host",
                linkedInURL: "https://www.linkedin.com/in/swiftlyrush/",
                twitterURL: "https://twitter.com/Adam9Rush",
                slackURL: "https://swiftleedsworkspace.slack.com/archives/D02ELG76VC0",
                photoURL: "https://swiftleeds.co.uk/img/team/rush.jpg"
            ))
            .previewDisplayName("With Role & All Links")
            
            // Team member without role
            TeamMemberView(member: TeamMember(
                name: "Adam Oxley",
                role: nil,
                linkedInURL: "https://www.linkedin.com/in/adam-oxley-41183a82/",
                twitterURL: "https://twitter.com/admoxly",
                slackURL: "https://swiftleedsworkspace.slack.com/team/U02DRL7KUCS",
                photoURL: "https://swiftleeds.co.uk/img/team/oxley.jpg"
            ))
            .previewDisplayName("No Role")
            
            // Team member with partial social links
            TeamMemberView(member: TeamMember(
                name: "Kannan Prasad",
                role: nil,
                linkedInURL: "https://www.linkedin.com/in/kannanprasad/",
                twitterURL: nil,
                slackURL: "https://swiftleedsworkspace.slack.com/archives/D0477TRS28G",
                photoURL: nil
            ))
            .previewDisplayName("Partial Links & No Photo")
            
            // Grid layout preview
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                TeamMemberView(member: TeamMember(
                    name: "James Sherlock",
                    role: "Production Team Lead",
                    linkedInURL: "https://www.linkedin.com/in/jamessherlockdeveloper/",
                    twitterURL: "https://twitter.com/JamesSherlouk",
                    slackURL: "https://swiftleedsworkspace.slack.com/archives/D05RK6AAV29",
                    photoURL: "https://swiftleeds.co.uk/img/team/sherlock.jpg"
                ))
                
                TeamMemberView(member: TeamMember(
                    name: "Joe Williams",
                    role: "Camera Operator",
                    linkedInURL: "https://www.linkedin.com/in/joe-williams-1676b871/",
                    twitterURL: "https://twitter.com/joedub_dev",
                    slackURL: "https://swiftleedsworkspace.slack.com/archives/C05N7JZE2NP",
                    photoURL: "https://swiftleeds.co.uk/img/team/joe.jpg"
                ))
            }
            .padding()
            .previewDisplayName("Grid Layout")
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
