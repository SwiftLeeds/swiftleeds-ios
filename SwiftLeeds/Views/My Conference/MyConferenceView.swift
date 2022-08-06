//
//  MyConferenceView.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 14/11/2021.
//

import SwiftUI

struct MyConferenceView: View {
    @StateObject private var viewModel = MyConferenceViewModel()
    @State private var selectedPresentation: Presentation?
    @State private var selectedActivity: Activity?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Divider()

                ScrollView {
                    VStack(spacing: Padding.cellGap) {
                        // TODO: Weather to come from Apple API
                        AnnouncementCell(label: "Leeds", value: "26℃", valueIcon: "cloud.sun.fill", gradientColors: [.weatherGradientStart, .weatherGradientEnd])
                            .previewDisplayName("Weather")

                        if let numberOfDaysToConference = viewModel.numberOfDaysToConference {
                            AnnouncementCell(label: "Get your ticket now!", value: "\(numberOfDaysToConference) days", valueIcon: "calendar.circle", gradientColors: [.buyTicketGradientStart, .buyTicketGradientEnd])
                                .previewDisplayName("Buy Ticket")
                        }

                        ForEach(viewModel.slots) { slot in
                            if let activity = slot.activity {
                                TalkCell(time: slot.startTime, details: activity.title)
                                    .onTapGesture {
                                        selectedActivity = activity
                                    }
                            }

                            if let presentation = slot.presentation {
                                TalkCell(time: slot.startTime, details: presentation.title, speaker: presentation.speaker?.name, company: presentation.speaker?.organisation.description, imageURL: presentation.speaker?.profileImage)
                                    .onTapGesture {
                                        selectedPresentation = presentation
                                    }
                            }
                        }
                    }
                    .padding(Padding.screen)
                }

                Divider()
            }
            .background(Color.background)
            .navigationTitle("SwiftLeeds")
            .task {
                try? await viewModel.loadSchedule()
            }
        }
        .sheet(item: $selectedPresentation) { presentation in
            SpeakerView(presentation: presentation)
        }
        .sheet(item: $selectedActivity) { activity in
            ActivityView(activity: activity)
        }
    }
}

struct MyConferenceView_Previews: PreviewProvider {
    static var previews: some View {
        MyConferenceView()
    }
}
