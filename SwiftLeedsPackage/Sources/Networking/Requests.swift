import Foundation

public enum Requests {
    public static let host = "swiftleeds.co.uk"
    public static let apiVersion1 = "/api/v1"
    public static let apiVersion2 = "/api/v2"

    public static var defaultDateDecodingStratergy: JSONDecoder.DateDecodingStrategy = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return .formatted(dateFormatter)
    }()
}
