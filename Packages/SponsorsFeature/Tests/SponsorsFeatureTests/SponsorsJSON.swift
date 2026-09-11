import Foundation

/// Payloads shaped like the real `api/v1/sponsors` response.
enum SponsorsJSON {
    static func list(_ sponsors: String...) -> Data {
        Data("{\"data\":[\(sponsors.joined(separator: ","))]}".utf8)
    }

    static func sponsor(
        id: String = "C39392A1-1478-4197-A9C4-0447BB5A0926",
        name: String = "CodeMagic",
        subtitle: String = "CI/CD for mobile dev teams",
        image: String = "https://example.invalid/codemagic.png",
        level: String = "platinum",
        url: String = "https://example.invalid/codemagic",
        jobs: String = "[]"
    ) -> String {
        """
        {
          "id": "\(id)",
          "name": "\(name)",
          "subtitle": "\(subtitle)",
          "image": "\(image)",
          "sponsorLevel": "\(level)",
          "url": "\(url)",
          "jobs": \(jobs)
        }
        """
    }

    static func job(
        id: String = "3E1E6E1C-6C1F-4C6A-9E7C-7B9E0E5A1D22",
        title: String = "Senior iOS Engineer",
        details: String = "Bringing all your Swift skills to the fore",
        location: String = "Leeds",
        url: String = "https://example.invalid/job"
    ) -> String {
        """
        {
          "id": "\(id)",
          "title": "\(title)",
          "details": "\(details)",
          "location": "\(location)",
          "url": "\(url)"
        }
        """
    }
}
