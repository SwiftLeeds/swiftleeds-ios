//
//  TalkCell.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 25/06/2022.
//

import SwiftUI
import CachedAsyncImage

struct TalkCell: View {
    private let time: String
    private let details: String
    private let isNext: Bool
    private let speakers: [Speaker]
    private let gradientColors: [Color]?

    @Environment(\.colorScheme) var colorScheme

    init(time: String, details: String, isNext: Bool = false, speakers: [Speaker] = [], gradientColors: [Color]? = nil) {
        self.time = time
        self.details = details
        self.isNext = isNext
        self.speakers = speakers
        self.gradientColors = gradientColors
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            timeLabel(time)

            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    if speakers.isEmpty == false {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(speakers.joinedNames)
                                    .font(.headline.weight(.medium))
                                    .multilineTextAlignment(.leading)

                                Text(speakers.joinedOrganisations)
                                    .font(.subheadline.weight(.medium))
                                    .opacity(0.6)
                            }

                            Spacer()

                            HStack(spacing: -5) {
                                ForEach(speakers) { speaker in
                                    CachedAsyncImage(
                                        url: URL(string: speaker.profileImage),
                                        content: { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(maxWidth: 40, maxHeight: 40)
                                                .clipShape(Circle())
                                        },
                                        placeholder: {
                                            Circle()
                                                .fill(.white)
                                                .opacity(0.3)
                                                .frame(maxWidth: 40, maxHeight: 40)
                                                .clipShape(Circle())
                                        }
                                    )
                                }
                            }
                        }
                    }

                    HStack {
                        Text(details)
                            .font(.body.weight(.regular))
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                }
                .padding(.trailing, 2)

                Image(systemName: "chevron.right")
            }
            .padding(Padding.cell)
            .frame(maxWidth: .infinity)
            .foregroundColor(isNext ? .white : .cellForeground)
            .background {
                if let gradientColors = gradientColors {
                    RoundedRectangle(cornerRadius: Constants.cellRadius)
                        .fill(LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .topTrailing))
                } else {
                    RoundedRectangle(cornerRadius: Constants.cellRadius)
                        .strokeBorder(Color.cellBorder)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private func timeLabel(_ value: String) -> some View {
        HStack(spacing: 7) {
            Image("Clock")

            Text(value)
                .foregroundColor(.cellForeground)

            Spacer()
        }
        .padding(.leading, 4)
    }

    private var accessibilityLabel: String {
        [time, speakers.joinedNames, speakers.joinedOrganisations, details.noEmojis]
            .filter { $0.isEmpty == false }
            .joined(separator: ", ")
    }
}

struct TalkCell_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Padding.cellGap) {
            TalkCell(time: "11:00", details: Presentation.donnyWalls.title, speakers: Presentation.donnyWalls.speakers)

            TalkCell(time: "12:00", details: "Lunch")

            TalkCell(time: "1:00", details: Presentation.skyBet.title, speakers: Presentation.skyBet.speakers)
        }
        .padding(Padding.screen)
        .background(Color.listBackground)
    }
}
