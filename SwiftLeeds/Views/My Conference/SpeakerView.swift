import DesignKit
import ScheduleFeature
import SwiftUI
import UIComponents

struct SpeakerView: View {
    let presentation: Presentation
    let showSlido: Bool

    @State private var showWebSheet = false

    @Environment(\.openURL) var openURL

    var body: some View {
        ScrollView {
            content
        }
        .background(Color.background, ignoresSafeAreaEdges: .all)
        .edgesIgnoringSafeArea(.top)
    }

    private var slidoGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [.buyTicketGradientStart, .buyTicketGradientEnd]),
            startPoint: .leading,
            endPoint: .trailing
        )
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

            VStack(spacing: Padding.screen) {
                StackedTileView(
                    primaryText: presentation.title,
                    secondaryText: presentation.synopsis,
                    secondaryColor: Color.primary
                )

                if let videoURL = presentation.videoURL.flatMap({ URL(string: $0) }) {
                    CommonTileView(
                        icon: "video.fill",
                        primaryText: "Watch video",
                        showChevron: true,
                        secondaryColor: Color.primary
                    )
                    .accessibilityHint("Opens the video")
                    .accessibilityAddTraits(.isButton)
                    .onTapGesture {
                        openURL(videoURL)
                    }
                }

                if showSlido, presentation.slidoURL?.isEmpty == false {
                    CommonTileButton(
                        icon: "questionmark.bubble.fill",
                        primaryText: "Ask Questions Now",
                        accessibilityHint: "Opens Slido to allow questions to be asked",
                        primaryColor: .white,
                        secondaryColor: .white.opacity(0.8),
                        backgroundStyle: slidoGradient,
                        onTap: {
                            showWebSheet.toggle()
                        }
                    )
                }

                ForEach(presentation.speakers) { speaker in
                    if !speaker.biography.isEmpty {
                        StackedTileView(
                            primaryText: "About\(presentation.speakers.count == 1 ? "" : ": \(speaker.name)")",
                            secondaryText: speaker.biography,
                            secondaryColor: Color.primary
                        )
                    }

                    if let twitter = speaker.twitter,
                       twitter.isEmpty == false,
                       let twitterURL = URL(string: "https://twitter.com/\(twitter)") {
                        CommonTileView(
                            primaryText: "Twitter",
                            secondaryText: "@\(twitter)",
                            secondaryColor: Color.primary
                        )
                        .accessibilityHint("Opens twitter for this speaker")
                        .accessibilityAddTraits(.isButton)
                        .onTapGesture {
                            openURL(twitterURL)
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
