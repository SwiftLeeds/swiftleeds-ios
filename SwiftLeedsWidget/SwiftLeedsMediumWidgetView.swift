//
//  SwiftLeedsMediumWidgetView.swift
//  SwiftLeedsWidgetExtension
//
//  Created by karim ebrahim on 09/09/2022.
//

import SwiftLeedsCore
import SwiftUI
import WidgetKit

struct SwiftLeedsMediumWidgetView: View {
    
    // MARK: - Pivate Properties
    
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

// MARK: - View Builders

extension SwiftLeedsMediumWidgetView {
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
            HStack {
                logoView
                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.cellForeground.opacity(0.1))
                        .frame(width: 100, height: 30, alignment: .center)
                    
                    Text(verbatim: "Up Next")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                }
            }
            Spacer()
            VStack(alignment: .leading, spacing: 4) {
                Text(time)
                    .font(.system(size: WidgetConstants.timeFontSize, weight: .medium))
                VStack(alignment: .leading) {
                    Text(speaker)
                        .font(.system(size: WidgetConstants.titleFontSize, weight: .bold, design: .default))
                        .foregroundColor(Color.accent)
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
        Image(Assets.Image.swiftLeedsIconWithNoBackground)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .transition(.opacity)
            .frame(width: WidgetConstants.logoImageWidth, height: WidgetConstants.logoImageHeight, alignment: .center)
    }
}

// MARK: - Widget Previews

struct SwiftLeedsMediumWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftLeedsMediumWidgetView(slot: Schedule.Slot(id: UUID(), date: Date(), startTime: "11:00 AM", duration: 1, activity: nil, presentation: Presentation.donnyWalls))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        
        SwiftLeedsMediumWidgetView(slot: Schedule.Slot(id: UUID(), date: Date(), startTime: "11:00 AM", duration: 1, activity: nil, presentation: Presentation.donnyWalls))
            .environment(\.colorScheme, .dark)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
