//
//  MyConferenceView.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 14/11/2021.
//

import SwiftUI

struct MyConferenceView: View {
    @StateObject private var viewModel = MyConferenceViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Divider()

                ScrollView {
                    VStack(spacing: Padding.cellGap) {
                        if let numberOfDaysToConference = viewModel.numberOfDaysToConference {
                            AnnouncementCell(label: "Get your ticket now!", value: "\(numberOfDaysToConference) days", valueIcon: "calendar.circle.fill", gradientColors: [.accent, .accent])
                                .previewDisplayName("Buy Ticket")
                        }

                        ForEach(viewModel.slots) { slot in
                            if let activity = slot.activity {
                                NavigationLink {
                                    ActivityView(activity: activity)
                                } label: {
                                    TalkCell(time: slot.startTime, details: activity.title)
                                        .transition(.opacity)
                                }
                            }

                            if let presentation = slot.presentation, let speakers = presentation.speakers {
                                NavigationLink {
                                    SpeakerView(presentation: presentation, showSlido: viewModel.showSlido)
                                } label: {
                                    TalkCell(time: slot.startTime, details: presentation.title, speakers: speakers)
                                        .transition(.opacity)
                                }
                            }
                        }
                    }
                    .animation(.easeInOut, value: viewModel.slots)
                    .padding(Padding.screen)
                }

                Divider()
            }
            .background(Color.listBackground)
            .navigationTitle("Schedule")
            .task {
                try? await viewModel.loadSchedule()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(.white)
    }
}

struct MyConferenceView_Previews: PreviewProvider {
    static var previews: some View {
        MyConferenceView()
    }
}
