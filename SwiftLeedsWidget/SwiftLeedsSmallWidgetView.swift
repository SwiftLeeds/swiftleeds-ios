//
//  SwiftLeedsSmallWidgetView.swift
//  SwiftLeedsWidgetExtension
//
//  Created by karim ebrahim on 08/09/2022.
//

import SwiftUI
import WidgetKit

struct SwiftLeedsSmallWidgetView: View {
    
    // MARK: - Pivate Properties
    
    private let slot: Schedule.Slot
    private let timeFontSize: CGFloat = 10
    private let titleFontSize: CGFloat = 14
    private let detailsFontSize: CGFloat = 14
    private let logoImageWidth: CGFloat = 45
    private let logoImageHeight: CGFloat = 45
    
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
            let speakers = presentation.speakers
            let firstSpeakerName = speakers.first?.name  ?? ""
            slotView(time: slot.startTime, speaker: firstSpeakerName, details: presentation.title)
        }
    }
    
    @ViewBuilder
    private func slotView(time: String, speaker: String = "", details: String) -> some View {
        ZStack {
            Color.background
            HStack {
                contentView(time: time, speaker: speaker, details: details)
            }
        }
    }
    
    @ViewBuilder
    private func contentView(time: String, speaker: String = "", details: String) -> some View {
        VStack(alignment: .leading) {
            logoView
            Spacer()
            VStack(alignment: .leading, spacing: 4) {
                Text(time)
                    .font(.system(size: timeFontSize, weight: .medium))
                VStack(alignment: .leading) {
                    Text(speaker)
                        .font(.system(size: titleFontSize, weight: .bold, design: .default))
                        .foregroundColor(Color.accent)
                        .lineLimit(2)
                    Text(details)
                        .font(.system(size: detailsFontSize, weight: .regular, design: .default))
                        .lineLimit(2)
                }
            }
        }
        .padding([.leading, .trailing, .bottom, .top], 16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private var logoView: some View {
        Image(Assets.Image.swiftLeedsIconWithNoBackground)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .transition(.opacity)
            .frame(width: logoImageWidth, height: logoImageHeight, alignment: .center)
    }
}

struct SwiftLeedsSmallWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftLeedsSmallWidgetView(slot: Schedule.Slot(id: UUID(), startTime: "11:00 AM", duration: 1, activity: nil, presentation: Presentation.skyBet))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        SwiftLeedsSmallWidgetView(slot: Schedule.Slot(id: UUID(), startTime: "11:00 AM", duration: 1, activity: nil, presentation: Presentation.skyBet))
            .environment(\.colorScheme, .dark)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
