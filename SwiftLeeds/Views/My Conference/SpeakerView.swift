//
//  SpeakerView.swift
//  SwiftLeeds
//
//  Created by LUCKY AGARWAL on 23/07/22.
//

import SwiftUI

struct SpeakerView: View {
    let presentation: Presentation
    let showSlido: Bool

    @State private var showWebSheet = false

    @Environment(\.openURL) var openURL

    var body: some View {
        SwiftLeedsContainer {
            ScrollView {
                content
            }
        }
        .edgesIgnoringSafeArea(.top)
    }

    private var content: some View {
        VStack(spacing: Padding.stackGap) {
            if presentation.speakers.isEmpty == false {
                FancyHeaderView(
                    title: presentation.speakers.joinedNames,
                    foregroundImageURLs: presentation.speakers.map { URL(string: $0.profileImage)! }
                )
            }

            VStack(spacing: Padding.screen){
                StackedTileView(
                    primaryText: presentation.title,
                    secondaryText: presentation.synopsis,
                    secondaryColor: Color.primary
                )

                if let videoURL = presentation.videoURL, videoURL.isEmpty == false {
                    CommonTileView(
                        icon: "video.fill",
                        primaryText: "Watch video",
                        showChevron: true,
                        secondaryColor: Color.primary
                    )
                    .accessibilityHint("Opens the video")
                    .accessibilityAddTraits(.isButton)
                    .onTapGesture {
                        openURL(URL(string: videoURL)!)
                    }
                }

                if showSlido, presentation.slidoURL?.isEmpty == false {
                    CommonTileButton(
                        icon: "questionmark.bubble.fill",
                        primaryText: "Ask Questions Now",
                        accessibilityHint: "Opens Slido to allow questions to be asked",
                        primaryColor: .white,
                        secondaryColor: .white.opacity(0.8),
                        backgroundStyle: LinearGradient(gradient: Gradient(colors:[.buyTicketGradientStart, .buyTicketGradientEnd]) ,startPoint: .leading, endPoint: .trailing),
                        onTap: {
                            showWebSheet.toggle()
                        }
                    )
                }

                ForEach(presentation.speakers) { speaker in
                    StackedTileView(
                        primaryText: "About\(presentation.speakers.count == 1 ? "" : ": \(speaker.name)")",
                        secondaryText: speaker.biography,
                        secondaryColor: Color.primary
                    )

                    if let twitter = speaker.twitter, twitter.isEmpty == false {
                        CommonTileView(
                            primaryText: "Twitter",
                            secondaryText: "@\(twitter)",
                            secondaryColor: Color.primary
                        )
                        .accessibilityHint("Opens twitter for this speaker")
                        .accessibilityAddTraits(.isButton)
                        .onTapGesture {
                            openURL(URL(string: "https://twitter.com/\(twitter)")!)
                        }
                    }
                }
            }
            .padding(Padding.screen)
        }
        .sheet(isPresented: $showWebSheet) {
            WebView(url: presentation.slidoURL ?? "")
                .edgesIgnoringSafeArea(.bottom)
        }
    }
}

struct SpeakerView_Previews: PreviewProvider {
    static var previews: some View {
        SpeakerView(presentation: .donnyWalls, showSlido: true)
            .previewDisplayName("Donny Wals")

        SpeakerView(presentation: .skyBet, showSlido: true)
            .previewDisplayName("Sky Bet")
    }
}
