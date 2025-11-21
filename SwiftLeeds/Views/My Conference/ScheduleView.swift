import DesignKit
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
        ScheduleView(slots: [], showSlido: true)
    }
}
