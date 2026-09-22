import Sharing

/// The name a stored preference is saved under. Changing a name resets every user's saved value.
public struct PreferenceName: Equatable, Hashable, Sendable {
    fileprivate let rawValue: String

    /// Creates a preference name.
    ///
    /// - Parameter rawValue: The storage key. It must not contain `.` or `@`.
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

extension SharedKey {
    /// A key that stores a string-backed value in app storage under `name`.
    public static func appStorage<Value>(_ name: PreferenceName) -> Self
    where Self == AppStorageKey<Value>, Value: RawRepresentable & Sendable, Value.RawValue == String {
        .appStorage(name.rawValue)
    }
}
