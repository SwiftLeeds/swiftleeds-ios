//
//  MyConferenceView.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 14/11/2021.
//

import SwiftUI

struct MyConferenceView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Divider()

                ScrollView {
                    VStack(spacing: Padding.cellGap) {
                        // TODO: Weather to come from Apple API
                        AnnouncementCell(label: "Leeds", value: "26℃", valueIcon: "cloud.sun.fill", gradientColors: [.weatherGradientStart, .weatherGradientEnd])
                            .previewDisplayName("Weather")

                        // TODO: Calculate days once data is available from API
                        AnnouncementCell(label: "Get your ticket now!", value: "69 Days", valueIcon: "calendar.circle", gradientColors: [.buyTicketGradientStart, .buyTicketGradientEnd])
                            .previewDisplayName("Buy Ticket")

                        // TODO: Retrieve sessions once available from API
                        TalkCell(time: "11:00", details: "Take crosswords to the next level with macOS catalyst. You’ll learn how to tick that checkbox and break free from the chains of the iPad.", isNext: true, speaker: "Joe Williams", company: "Expodition", gradientColors: [.nextTalkGradientStart, .nextTalkGradientEnd])

                        TalkCell(time: "12:00", details: "Lunch")

                        TalkCell(time: "13:00", details: "Something about chats", speaker: "Adam Rush", company: "Stream")
                    }
                    .padding(Padding.screen)
                }

                Divider()
            }
            .background(Color.background)
            .navigationTitle("Swift Leeds")
        }
    }

    func timeLabel(_ value: String) -> some View {
        HStack {
            Text(value)
            Spacer()
        }
    }
}

struct MyConferenceView_Previews: PreviewProvider {
    static var previews: some View {
        MyConferenceView()
    }
}
