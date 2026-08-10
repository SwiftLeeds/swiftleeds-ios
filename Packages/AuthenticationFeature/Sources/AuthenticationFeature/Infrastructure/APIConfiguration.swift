import Dependencies
import Foundation

public struct APIConfiguration: Sendable {
    public let baseURL: URL

    public init(baseURL: URL) {
        self.baseURL = baseURL
    }
}

extension APIConfiguration: TestDependencyKey {
    public static let testValue = APIConfiguration(baseURL: URL(string: "https://example.com")!)
}

extension DependencyValues {
    public var apiConfiguration: APIConfiguration {
        get { self[APIConfiguration.self] }
        set { self[APIConfiguration.self] = newValue }
    }
}
