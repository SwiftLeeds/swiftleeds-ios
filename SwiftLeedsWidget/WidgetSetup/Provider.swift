import Dependencies
import ScheduleFeature
import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SwiftLeedsWidgetEntry {
        SwiftLeedsWidgetEntry(date: Date(), slot: Schedule.Slot(id: UUID(), date: Date(), startTime: "11:00 AM", duration: 1, activity: nil, presentation: Presentation.donnyWalls))
    }

    func getSnapshot(in context: Context, completion: @escaping (SwiftLeedsWidgetEntry) -> Void) {
        let entry = SwiftLeedsWidgetEntry(date: Date(), slot: Schedule.Slot(id: UUID(), date: Date(), startTime: "11:00 AM", duration: 1, activity: nil, presentation: Presentation.donnyWalls))
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SwiftLeedsWidgetEntry>) -> Void) {
        @Dependency(\.fetchCurrentSchedule) var fetchCurrentSchedule

        Task {
            let schedule = try? await fetchCurrentSchedule()
            completion(Timeline(entries: entries(for: schedule), policy: .after(nextUpdateTime)))
        }
    }

    private func entries(for schedule: Schedule?) -> [SwiftLeedsWidgetEntry] {
        guard let schedule else { return [] }

        return schedule.data.days
            .flatMap(\.slots)
            .sorted { $0.startTime < $1.startTime }
            .map { SwiftLeedsWidgetEntry(date: buildDate(for: $0), slot: $0) }
            .filter { $0.date > Date() }
    }

    private var nextUpdateTime: Date {
        let anHour: TimeInterval = 60 * 60
        return Calendar.autoupdatingCurrent.startOfDay(for: Date()).addingTimeInterval(anHour)
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
