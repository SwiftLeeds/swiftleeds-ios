#if canImport(UIKit)
import DesignKit
import ScheduleFeature
import SwiftUI

package struct DayView: View {
    private let slots: [Schedule.Slot]
    private let showSlido: Bool

    package init(slots: [Schedule.Slot], showSlido: Bool) {
        self.slots = slots
        self.showSlido = showSlido
    }

    package var body: some View {
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

struct DayView_Previews: PreviewProvider {
    static var previews: some View {
        DayView(slots: [], showSlido: true)
    }
}
#endif
