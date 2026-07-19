import Foundation

public enum Requests {
    public static var host: String {
        guard let host = Bundle.main.object(forInfoDictionaryKey: "APIHost") as? String, !host.isEmpty else {
            assertionFailure("Missing Info.plist key: APIHost")
            return ""
        }
        return host
    }
    public static let apiVersion1 = "/api/v1"
    public static let apiVersion2 = "/api/v2"

    public static var defaultDateDecodingStratergy: JSONDecoder.DateDecodingStrategy = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return .formatted(dateFormatter)
    }()
}
