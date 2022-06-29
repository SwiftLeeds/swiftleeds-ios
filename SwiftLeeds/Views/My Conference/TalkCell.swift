//
//  TalkCell.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 25/06/2022.
//

import SwiftUI

struct TalkCell: View {
    private let time: String
    private let details: String
    private let isNext: Bool
    private let speaker: String?
    private let company: String?
    private let gradientColors: [Color]?

    @Environment(\.colorScheme) var colorScheme

    init(time: String, details: String, isNext: Bool = false, speaker: String? = nil, company: String? = nil, gradientColors: [Color]? = nil) {
        self.time = time
        self.details = details
        self.isNext = isNext
        self.speaker = speaker
        self.company = company
        self.gradientColors = gradientColors
    }

    var body: some View {
        VStack(spacing: 6) {
            timeLabel(time)

            VStack(alignment: .leading, spacing: 8) {
                if let speaker = speaker {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(speaker)
                            .fontWeight(.medium)

                        if let company = company {
                            Text(company)
                                .fontWeight(.medium)
                                .opacity(0.5)
                        }
                    }
                }

                HStack {
                    Text(details)
                        .fontWeight(.light)
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
    }

    func timeLabel(_ value: String) -> some View {
        HStack {
            Text(value)
            Spacer()
        }
    }
}

struct TalkCell_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Padding.cellGap) {
            TalkCell(time: "11:00", details: "Something about chats", speaker: "Adam Rush", company: "Stream")

            TalkCell(time: "12:00", details: "Lunch")
        }
        .padding(Padding.screen)
        .background(Color.gray)
    }
}
