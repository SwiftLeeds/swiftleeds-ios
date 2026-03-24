import SharedAssets
import SwiftUI
import WidgetKit

struct SwiftLeedsSmallWidgetView: View {
    
    // MARK: - Private Properties
    
    private let slot: Schedule.Slot
    
    // MARK: - Init
    
    init(slot: Schedule.Slot) {
        self.slot = slot
    }
    
    // MARK: - Body View
    
    var body: some View {
        buildSlotView(for: slot)
    }
}

// MARK: - Widget Previews

extension SwiftLeedsSmallWidgetView {
    @ViewBuilder
    private func buildSlotView(for slot: Schedule.Slot) -> some View {
        if let activity = slot.activity {
            slotView(time: slot.startTime, speaker: activity.title, details: activity.description!)
        }

        if let presentation = slot.presentation {
            let speakers = presentation.speakers.joinedNames
            slotView(time: slot.startTime, speaker: speakers, details: presentation.title)
        }
    }
    
    private func slotView(time: String, speaker: String = "", details: String) -> some View {
        ZStack {
            Color.background
            contentView(time: time, speaker: speaker, details: details)
        }
    }
    
    private func contentView(time: String, speaker: String = "", details: String) -> some View {
        VStack(alignment: .leading) {
            logoView
            Spacer()
            VStack(alignment: .leading, spacing: 4) {
                Text(time)
                    .font(.system(size: WidgetConstants.timeFontSize, weight: .medium))
                VStack(alignment: .leading) {
                    Text(speaker)
                        .font(.system(size: WidgetConstants.titleFontSize, weight: .bold, design: .default))
                        .foregroundColor(Color.accent)
                        .lineLimit(2)
                    Text(details)
                        .font(.system(size: WidgetConstants.detailsFontSize, weight: .regular, design: .default))
                        .lineLimit(2)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var logoView: some View {
        Image.swiftLeedsIcon
            .resizable()
            .aspectRatio(contentMode: .fill)
            .transition(.opacity)
            .frame(width: WidgetConstants.logoImageWidth, height: WidgetConstants.logoImageHeight, alignment: .center)
    }
}

struct SwiftLeedsSmallWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftLeedsSmallWidgetView(slot: Schedule.Slot(id: UUID(), date: Date(), startTime: "11:00 AM", duration: 1, activity: nil, presentation: Presentation.skyBet))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        SwiftLeedsSmallWidgetView(slot: Schedule.Slot(id: UUID(), date: Date(), startTime: "11:00 AM", duration: 1, activity: nil, presentation: Presentation.skyBet))
            .environment(\.colorScheme, .dark)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
