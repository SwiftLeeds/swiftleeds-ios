import Foundation

// Payloads shaped like the real `api/v1/local` response.
enum LocalJSON {
    static func list(_ categories: String...) -> Data {
        Data("{\"data\":[\(categories.joined(separator: ","))]}".utf8)
    }

    static func category(
        id: String = "6F1C1E0A-2B7D-4B8E-9E3A-0D5C7A1B2C3D",
        name: String = "Food",
        symbolName: String = "takeoutbag.and.cup.and.straw.fill",
        locations: String...
    ) -> String {
        """
        {
          "id": "\(id)",
          "name": "\(name)",
          "symbolName": "\(symbolName)",
          "locations": [\(locations.joined(separator: ","))]
        }
        """
    }

    static func location(
        id: String = "9A4E2C7B-5D1F-4A3E-8B6C-1E2D3F4A5B6C",
        name: String = "Trinity Kitchen",
        lat: Double = 53.797378,
        lon: Double = -1.545209,
        url: String = "https://example.invalid/trinity-kitchen"
    ) -> String {
        """
        {
          "id": "\(id)",
          "name": "\(name)",
          "lat": \(lat),
          "lon": \(lon),
          "url": "\(url)"
        }
        """
    }
}
