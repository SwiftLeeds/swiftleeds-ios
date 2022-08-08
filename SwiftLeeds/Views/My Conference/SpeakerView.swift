//
//  SpeakerView.swift
//  SwiftLeeds
//
//  Created by LUCKY AGARWAL on 23/07/22.
//

import SwiftUI

struct SpeakerView: View {
    let presentation: Presentation

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
            if let speaker = presentation.speaker {
                FancyHeaderView(
                    title: speaker.name,
                    foregroundImageURL: URL(string: speaker.profileImage),
                    backgroundImageName: Assets.Image.playhouseImage
                )
            }

            VStack(spacing: Padding.screen){
                StackedTileView(
                    primaryText: presentation.title,
                    secondaryText: presentation.synopsis,
                    secondaryColor: Color.primary
                )

                // TODO: Show slido link here
                CommonTileButton(
                    primaryText: "Ask Questions Now",
                    secondaryText: nil,
                    primaryColor: .white,
                    secondaryColor: .white.opacity(0.8),
                    backgroundStyle: LinearGradient(gradient: Gradient(colors:[.buyTicketGradientStart, .buyTicketGradientEnd]) ,startPoint: .leading, endPoint: .trailing),
                    onTap: {}
                )
                .accessibilityHint("Double tap to ask a question")

                if let speaker = presentation.speaker {
                    StackedTileView(
                        primaryText: "About",
                        secondaryText: speaker.biography,
                        secondaryColor: Color.primary
                    )

                    if let twitter = speaker.twitter {
                        CommonTileView(
                            primaryText: "Twitter",
                            secondaryText: "@\(twitter)",
                            secondaryColor: Color.primary
                        )
                        .accessibilityHint("Double tap to view on Twitter")
                        .accessibilityAddTraits(.isButton)
                        .onTapGesture {
                            openURL(URL(string: "https://twitter.com/\(twitter)")!)
                        }
                    }
                }
            }
            .padding(Padding.screen)
        }
    }
}

struct SpeakerView_Previews: PreviewProvider {
    static var previews: some View {
        SpeakerView(presentation: .donnyWalls)
    }
}
