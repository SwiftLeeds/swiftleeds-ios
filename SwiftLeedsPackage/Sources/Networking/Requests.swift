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

    // Custom strategy for v2 schedule endpoint (handles both ISO8601 and dd-MM-yyyy)
    public static var scheduleDateDecodingStrategy: JSONDecoder.DateDecodingStrategy = {
        return .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // Try ISO8601 first (for slot dates)
            if let date = ISO8601DateFormatter().date(from: dateString) {
                return date
            }

            // Fallback to dd-MM-yyyy format (for event dates)
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            if let date = formatter.date(from: dateString) {
                return date
            }

            // If neither works, throw an error
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Date string does not match expected format. Expected ISO8601 or dd-MM-yyyy, got: \(dateString)"
            )
        }
    }()
}
