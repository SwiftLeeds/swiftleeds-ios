//
//  ScheduleView.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 21/08/2023.
//

import SwiftUI

struct ScheduleView: View {
    let slots: [Schedule.Slot]
    let showSlido: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: Padding.cellGap) {
                ForEach(slots) { slot in
                    if let activity = slot.activity {
                        NavigationLink {
                            ActivityView(activity: activity)
                        } label: {
                            TalkCell(time: slot.startTime, details: activity.title)
                                .transition(.opacity)
                        }
                    }

                    if let presentation = slot.presentation {
                        NavigationLink {
                            SpeakerView(presentation: presentation,
                                        showSlido: showSlido)
                        } label: {
                            TalkCell(time: slot.startTime,
                                     details: presentation.title,
                                     speakers: presentation.speakers)
                            .transition(.opacity)
                        }
                    }
                }
            }
            .animation(.easeInOut, value: slots)
            .padding(Padding.screen)
        }
    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ScheduleView(slots: [
                Schedule.Slot(
                    id: UUID(),
                    date: ISO8601DateFormatter().date(from: "2025-10-07T00:00:00Z"),
                    startTime: "10:00",
                    duration: 45,
                    activity: nil,
                    presentation: Presentation.donnyWalls
                ),
                Schedule.Slot(
                    id: UUID(),
                    date: ISO8601DateFormatter().date(from: "2025-10-07T00:00:00Z"),
                    startTime: "12:30",
                    duration: 75,
                    activity: Activity.lunch,
                    presentation: nil
                )
            ], showSlido: true)
            .navigationTitle("Schedule")
        }
        .navigationViewStyle(.stack)
    }
}
