import Foundation

enum ConferenceConfig {
    private static func value(for key: String) -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String, !value.isEmpty else {
            fatalError("Missing Info.plist key: \(key)")
        }
        return value
    }

    static let apiHost: String = value(for: "APIHost")
    static let pushURL: String = "https://www.\(apiHost)/push"
    static let contactEmail: String = value(for: "ContactEmail")
    static let appGroupIdentifier: String = value(for: "AppGroupIdentifier")
    static let conferenceName: String = value(for: "CFBundleDisplayName")
}
