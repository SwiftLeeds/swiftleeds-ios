import Foundation

enum ConferenceConfig {
    static let apiHost: String = value(for: "APIHost")

    static let apiURL: URL = {
        guard let url = URL(string: "https://\(apiHost)") else {
            fatalError("APIHost is not a valid URL host: \(apiHost)")
        }
        return url
    }()

    static let pushURL: String = "https://www.\(apiHost)/push"
    static let contactEmail: String = value(for: "ContactEmail")
    static let appVersion: String = value(for: "CFBundleShortVersionString")
    static let appGroupIdentifier: String = value(for: "AppGroupIdentifier")
    static let conferenceName: String = value(for: "CFBundleDisplayName")

    /// Returns the string stored under a key in the app's Info.plist.
    ///
    /// - Parameter key: The Info.plist key to read.
    /// - Returns: The non-empty string for `key`.
    /// - Precondition: The key must exist and hold a non-empty string.
    private static func value(for key: String) -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String, !value.isEmpty else {
            fatalError("Missing Info.plist key: \(key)")
        }
        return value
    }
}
