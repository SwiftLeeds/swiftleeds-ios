import Dependencies
import Foundation
import LocalFeature
import NetworkKit
import Testing

// Drives the composed `liveValue` with only the transport stubbed.
@Suite struct LocationCategoriesRepositoryIntegrationTests {
    @Test func whenServerReturnsValidList_shouldReturnCategories() async throws {
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

    @Test func whenRequestThrows_shouldThrowCouldNotReachServer() async throws {
        await withDependencies {
            $0.httpClient = .failing(with: URLError(.notConnectedToInternet))
        } operation: {
            await #expect(throws: LocationCategoryFetchError.couldNotReachServer) {
                try await LocationCategoriesRepository.liveValue.fetch()
            }
        }
    }

    @Test func whenBodyCannotBeDecoded_shouldThrowInvalidResponse() async throws {
        await withDependencies {
            $0.httpClient = .responding(with: Data("nonsense".utf8), statusCode: 200)
        } operation: {
            await #expect(throws: LocationCategoryFetchError.invalidResponse) {
                try await LocationCategoriesRepository.liveValue.fetch()
            }
        }
    }

    @Test func whenMapperThrows_shouldThrowInvalidResponse() async throws {
        let data = LocalJSON.list(LocalJSON.category(locations: LocalJSON.location(lat: 91)))

        await withDependencies {
            $0.httpClient = .responding(with: data, statusCode: 200)
        } operation: {
            await #expect(throws: LocationCategoryFetchError.invalidResponse) {
                try await LocationCategoriesRepository.liveValue.fetch()
            }
        }
    }

    @Test(arguments: [404, 500])
    func whenStatusIsNotOK_shouldThrowUnknown(statusCode: Int) async throws {
        let data = LocalJSON.list(LocalJSON.category())

        await withDependencies {
            $0.httpClient = .responding(with: data, statusCode: statusCode)
        } operation: {
            await #expect(throws: LocationCategoryFetchError.unknown) {
                try await LocationCategoriesRepository.liveValue.fetch()
            }
        }
    }

    @Test func whenMapperIsReplaced_shouldReturnItsCategories() async throws {
        let data = LocalJSON.list(LocalJSON.category(name: "ignored"))
        let expected = LocationCategory.fixture(name: "From the mapper")

        let categories = try await withDependencies {
            $0.httpClient = .responding(with: data, statusCode: 200)
            $0.locationCategoryMapper = LocationCategoryMapper { _ in [expected] }
        } operation: {
            try await LocationCategoriesRepository.liveValue.fetch()
        }

        #expect(categories == [expected])
    }
}
