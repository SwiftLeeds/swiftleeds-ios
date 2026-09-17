import Dependencies
import Foundation
import LocalFeature
import NetworkKit
import Testing

// Drives the composed `liveValue` with only the transport stubbed.
@Suite struct LocationCategoriesRepositoryIntegrationTests {
    @Test func whenServerAnswersWell_shouldReturnCategories() async throws {
        let id = UUID()
        let data = LocalJSON.list(
            LocalJSON.category(id: id.uuidString, name: "Food", locations: LocalJSON.location(name: "Trinity Kitchen"))
        )

        let categories = try await withDependencies {
            $0.httpClient = .responding(with: data, statusCode: 200)
        } operation: {
            try await LocationCategoriesRepository.liveValue.fetch()
        }

        #expect(categories.map(\.id) == [LocationCategoryID(id)])
        #expect(categories.first?.locations.map(\.name) == ["Trinity Kitchen"])
    }
}
