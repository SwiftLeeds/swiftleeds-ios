import Foundation

extension LocalScheduleStore {
    /// A store in an app group, so another process in the same group reads what this one saves.
    ///
    /// Keeps nothing when the app group is unavailable.
    public static func appGroup(_ identifier: AppGroupIdentifier) -> LocalScheduleStore {
        let suiteName = String(identifier)

        return LocalScheduleStore(
            load: { request in
                UserDefaults(suiteName: suiteName)?.data(forKey: key(for: request))
                    .flatMap { try? PropertyListDecoder().decode(StoredSchedule.self, from: $0) }
            },
            save: { stored, request in
                guard let data = try? PropertyListEncoder().encode(stored) else { return }
                UserDefaults(suiteName: suiteName)?.set(data, forKey: key(for: request))
            }
        )
    }

    /// The widget reads the current conference under this exact key.
    private static func key(for request: ScheduleRequest) -> String {
        switch request {
        case .current:
            "Schedule"
        case let .event(event):
            "Schedule-\(event.uuidString)"
        }
    }
}
