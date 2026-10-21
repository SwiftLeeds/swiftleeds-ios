import Foundation

/// Where a person is in a session's day, which the gallery fakes with a launch argument.
enum SessionMoment: String {
    /// Twelve minutes before the session starts.
    case before

    /// Ten minutes after the session starts.
    case during

    /// Ten minutes after the session ends.
    case after
}

// MARK: - Constants

extension SessionMoment {
    /// The length of a minute, in seconds.
    private static let minute: TimeInterval = 60

    /// How long before the start the moment `before` falls.
    private static let leadTime = 12 * minute

    /// How far past a boundary the moments `during` and `after` fall.
    private static let elapsed = 10 * minute
}

// MARK: - Time

extension SessionMoment {
    /// Returns the time this moment pretends to be, for a session.
    ///
    /// - Parameter session: The session the moment is measured against.
    /// - Returns: A time just before, inside or just after the session.
    func now(for session: SampleSession) -> Date {
        switch self {
        case .before: session.start.addingTimeInterval(-Self.leadTime)
        case .during: session.start.addingTimeInterval(Self.elapsed)
        case .after: session.end.addingTimeInterval(Self.elapsed)
        }
    }

    /// Returns the words on the chip above a session's title.
    ///
    /// - Parameter session: The session the moment is measured against.
    /// - Returns: How long until the session starts, "On now" during it, or `nil` after it.
    func chipText(for session: SampleSession) -> String? {
        switch self {
        case .before: startsIn(for: session)
        case .during: "On now"
        case .after: nil
        }
    }

    /// Returns how long until a session starts, in words.
    ///
    /// - Parameter session: The session the moment is measured against.
    /// - Returns: The wait before the session, such as "in 12 min", or `nil` once it has started.
    private func startsIn(for session: SampleSession) -> String? {
        guard self == .before else { return nil }
        let wait = Duration.seconds(session.start.timeIntervalSince(now(for: session)))
        return "in \(wait.formatted(.units(allowed: [.minutes], width: .abbreviated)))"
    }
}
