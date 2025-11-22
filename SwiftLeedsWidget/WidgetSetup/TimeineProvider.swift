import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SwiftLeedsWidgetEntry {
        SwiftLeedsWidgetEntry(date: Date(), slot: Schedule.Slot(id: UUID(), date: Date(), startTime: "11:00 AM", duration: 1, activity: nil, presentation: Presentation.donnyWalls))
    }

    func getSnapshot(in context: Context, completion: @escaping (SwiftLeedsWidgetEntry) -> ()) {
        let entry = SwiftLeedsWidgetEntry(date: Date(), slot: Schedule.Slot(id: UUID(), date: Date(), startTime: "11:00 AM", duration: 1, activity: nil, presentation: Presentation.donnyWalls))
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SwiftLeedsWidgetEntry>) -> ()) {
        var entries: [SwiftLeedsWidgetEntry] = []
        var slots: [Schedule.Slot] = []

        do {
            if let data = UserDefaults(suiteName: "group.uk.co.swiftleeds")?.data(forKey: "Schedule") {
                // Decode the full schedule and flatten days into slots
                let schedule = try PropertyListDecoder().decode(Schedule.self, from: data)
                slots = schedule.data.days.flatMap { $0.slots }.sorted { $0.startTime < $1.startTime }
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
        guard let slotDate = slot.date else { return Date() }

        let slotTime = slot.startTime
        let slotTimeComponents = slotTime.components(separatedBy: ":")
        let slotHour = Int(slotTimeComponents.first ?? "0") ?? 0
        let slotMinute = Int(slotTimeComponents.last ?? "0") ?? 0

        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: slotDate)
        dateComponents.hour = slotHour
        dateComponents.minute = slotMinute
        dateComponents.timeZone = TimeZone.current

        return Calendar.current.date(from: dateComponents) ?? Date()
    }
}
