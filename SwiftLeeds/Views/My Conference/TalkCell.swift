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
    private let speaker: String?
    private let company: String?
    private let imageURL: String?
    private let gradientColors: [Color]?

    @Environment(\.colorScheme) var colorScheme

    init(time: String, details: String, isNext: Bool = false, speaker: String? = nil, company: String? = nil, imageURL: String? = nil, gradientColors: [Color]? = nil) {
        self.time = time
        self.details = details
        self.isNext = isNext
        self.speaker = speaker
        self.company = company
        self.imageURL = imageURL
        self.gradientColors = gradientColors
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            timeLabel(time)

            VStack(alignment: .leading, spacing: 8) {
                if let speaker = speaker {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(speaker)
                                .font(.headline.weight(.medium))

                            if let company = company {
                                Text(company)
                                    .font(.subheadline.weight(.medium))
                                    .opacity(0.6)
                            }
                        }

                        Spacer()

                        if let imageURL = imageURL {
                            CachedAsyncImage(
                                url: URL(string: "\(BaseURL.image)\(imageURL)"),
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

                HStack {
                    Text(details)
                        .font(.body.weight(.regular))
                    Spacer()
                }
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
                        .fill(Color.cellBackground)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private func timeLabel(_ value: String) -> some View {
        HStack {
            Text(value)
            Spacer()
        }
    }

    private var accessibilityLabel: String {
        return [time, speaker, company, details.noEmojis].compactMap { $0 }.joined(separator: ", ")
    }
}

struct TalkCell_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Padding.cellGap) {
            TalkCell(time: "11:00", details: "Something about chats", speaker: "Adam Rush", company: "Stream", imageURL: "https://swiftleeds-speakers.s3.eu-west-2.amazonaws.com/adam.jpg-A5B77EEF-07F8-4EB9-A160-795CB42D814E")

            TalkCell(time: "12:00", details: "Lunch")
        }
        .padding(Padding.screen)
        .background(Color.gray)
    }
}
