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

                if viewModel.slots.isEmpty {
                    empty
                } else {
                    schedule
                }

                Divider()
            }
            .background(Color.listBackground)
            .navigationTitle("Schedule")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(.white)
        .task {
            try? await viewModel.loadSchedule()
        }
    }

    private var schedule: some View {
        ScrollView {
            VStack(spacing: Padding.cellGap) {
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
                            SpeakerView(presentation: presentation,
                                        showSlido: viewModel.showSlido)
                        } label: {
                            TalkCell(time: slot.startTime,
                                     details: presentation.title,
                                     speakers: speakers)
                            .transition(.opacity)
                        }
                    }
                }
            }
            .animation(.easeInOut, value: viewModel.slots)
            .padding(Padding.screen)
        }
    }

    @ViewBuilder
    private var tickets: some View {
        if let numberOfDaysToConference = viewModel.numberOfDaysToConference {
            AnnouncementCell(label: "Get your ticket now!",
                             value: "\(numberOfDaysToConference) days",
                             valueIcon: "calendar.circle.fill",
                             gradientColors: [.accent, .accent])
                .previewDisplayName("Buy Ticket")
        }
    }

    private var empty: some View {
        VStack(spacing: 10) {
            Spacer()

            Image(systemName: "signpost.right.and.left")
                .font(.system(size: 60))

            Text("Come back soon")
                .font(.title)

            Text("We're working on filling this schedule")
                .font(.subheadline)

            Spacer()
        }
        .foregroundColor(.cellForeground)
    }
}

struct MyConferenceView_Previews: PreviewProvider {
    static var previews: some View {
        MyConferenceView()
    }
}
