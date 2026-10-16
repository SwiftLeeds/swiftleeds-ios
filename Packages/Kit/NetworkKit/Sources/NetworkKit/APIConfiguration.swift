import Dependencies
import Foundation

public struct APIConfiguration: Sendable {
    public let baseURL: URL

    public init(baseURL: URL) {
        self.baseURL = baseURL
    }
}

extension APIConfiguration: TestDependencyKey {
    public static var testValue: APIConfiguration {
        guard let baseURL = URL(string: "https://example.com") else {
            reportIssue("APIConfiguration.testValue could not parse its base URL")
            return APIConfiguration(baseURL: URL(filePath: "/dev/null"))
        }
        return APIConfiguration(baseURL: baseURL)
    }
}

extension DependencyValues {
    public var apiConfiguration: APIConfiguration {
        get { self[APIConfiguration.self] }
        set { self[APIConfiguration.self] = newValue }
    }
}
