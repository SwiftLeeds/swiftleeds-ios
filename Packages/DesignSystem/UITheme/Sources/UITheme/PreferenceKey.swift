import Sharing

/// The key a stored preference is saved under. Changing a key resets every user's saved value.
public struct PreferenceKey: Equatable, Hashable, Sendable {
    fileprivate let rawValue: String

    /// Creates a preference key.
    ///
    /// - Parameter rawValue: The storage key. It must not contain `.` or `@`.
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

extension SharedKey {
    /// A shared key that stores a string-backed value in app storage under `key`.
    public static func appStorage<Value>(_ key: PreferenceKey) -> Self
    where Self == AppStorageKey<Value>, Value: RawRepresentable & Sendable, Value.RawValue == String {
        .appStorage(key.rawValue)
    }
}
