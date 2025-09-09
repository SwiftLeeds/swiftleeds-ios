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
                let imageURLs = presentation.speakers.compactMap { speaker in
                    speaker.profileImage.isEmpty ? nil : URL(string: speaker.profileImage)
                }
                FancyHeaderView(
                    title: presentation.speakers.joinedNames,
                    foregroundImageURLs: imageURLs
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
                
                NavigationLink {
                    TalkRatingView(presentation: presentation)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Rate This Talk")
                                    .font(.body.weight(.medium))
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "star.fill")
                                    .foregroundColor(.accent)
                                Text("4.6")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.secondary)
                    }
                    .padding(Padding.cell)
                    .background(
                        RoundedRectangle(cornerRadius: Constants.cellRadius)
                            .fill(Color.cellBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: Constants.cellRadius)
                            .stroke(Color.cellBorder, lineWidth: 1)
                    )
                }
                .accessibilityHint("Rate and review this presentation")

                ForEach(presentation.speakers) { speaker in
                    if !speaker.biography.isEmpty {
                        StackedTileView(
                            primaryText: "About\(presentation.speakers.count == 1 ? "" : ": \(speaker.name)")",
                            secondaryText: speaker.biography,
                            secondaryColor: Color.primary
                        )
                    }

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
        NavigationView {
            SpeakerView(presentation: .donnyWalls, showSlido: true)
        }
        .navigationViewStyle(.stack)
        .previewDisplayName("Donny Wals")

        NavigationView {
            SpeakerView(presentation: .skyBet, showSlido: true)
        }
        .navigationViewStyle(.stack)
        .previewDisplayName("Sky Bet")
    }
}
