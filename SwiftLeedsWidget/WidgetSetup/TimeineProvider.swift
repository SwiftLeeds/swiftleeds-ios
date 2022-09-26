//
//  TimelineProvider.swift
//  SwiftLeedsWidgetExtension
//
//  Created by Karim Ebrahem on 11/09/2022.
//  

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SwiftLeedsWidgetEntry {
        SwiftLeedsWidgetEntry(date: Date(), slot: Schedule.Slot(id: UUID(), startTime: "11:00 AM", duration: 1, activity: nil, presentation: Presentation.donnyWalls))
    }

    func getSnapshot(in context: Context, completion: @escaping (SwiftLeedsWidgetEntry) -> ()) {
        let entry = SwiftLeedsWidgetEntry(date: Date(), slot: Schedule.Slot(id: UUID(), startTime: "11:00 AM", duration: 1, activity: nil, presentation: Presentation.donnyWalls))
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SwiftLeedsWidgetEntry>) -> ()) {
        var entries: [SwiftLeedsWidgetEntry] = []
        var slots: [Schedule.Slot] = []
        
        do {
            if let data = UserDefaults(suiteName: "group.uk.co.swiftleeds")?.data(forKey: "Slots") {
                slots = try PropertyListDecoder().decode([Schedule.Slot].self, from: data)
            }
            
            for slot in slots {
                let date = buildDate(for: slot)
                if date > Date() {
                    let entry = SwiftLeedsWidgetEntry(date: date, slot: slot)
                    entries.append(entry)
                }
            }

            let nextUpdateTime = Calendar.autoupdatingCurrent.date(byAdding: .hour, value: 1, to: Calendar.autoupdatingCurrent.startOfDay(for: Date()))!
            let timeline = Timeline(entries: entries, policy: .after(nextUpdateTime))
            completion(timeline)
        } catch {
            let nextUpdateTime = Calendar.autoupdatingCurrent.date(byAdding: .minute, value: 5, to: Calendar.autoupdatingCurrent.startOfDay(for: Date()))!
            let timeline = Timeline(entries: entries, policy: .after(nextUpdateTime))
            completion(timeline)
        }
    }
    
    private func buildDate(for slot: Schedule.Slot) -> Date {
        let slotTime = slot.startTime
        let slotTimeComponents = slotTime.components(separatedBy: ":")
        let slotHour = Int(slotTimeComponents.first ?? "0")
        let slotMinute = Int(slotTimeComponents.last ?? "0")
        
        var dateComponents = DateComponents()
        dateComponents.year = 2022
        dateComponents.month = 10
        dateComponents.day = 20
        dateComponents.timeZone = TimeZone.current
        dateComponents.hour = slotHour
        dateComponents.minute = slotMinute
        let userCalendar = Calendar(identifier: .gregorian)
        let dateTime = userCalendar.date(from: dateComponents) ?? Date()
        
        return dateTime
    }
}
