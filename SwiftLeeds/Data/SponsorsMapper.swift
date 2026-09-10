import Dependencies
import Foundation
import NetworkKit

struct SponsorsMapper: Sendable {
    enum ResponseError: Error {
        case couldNotDecode(any Error)
        case unexpectedStatus(HTTPStatus)
    }

    var map: @Sendable (Data, HTTPURLResponse) throws(ResponseError) -> Sponsors

    init(map: @escaping @Sendable (Data, HTTPURLResponse) throws(ResponseError) -> Sponsors) {
        self.map = map
    }
}

extension SponsorsMapper {
    static let live = SponsorsMapper { data, response throws(ResponseError) in
        switch response.status {
        case .ok:
            do {
                return try JSONDecoder().decode(Sponsors.self, from: data)
            } catch {
                throw .couldNotDecode(error)
            }
        default:
            throw .unexpectedStatus(response.status)
        }
    }
}

private enum SponsorsMapperKey: DependencyKey {
    static var liveValue: SponsorsMapper { .live }
    static var testValue: SponsorsMapper { liveValue }
}

extension DependencyValues {
    var sponsorsMapper: SponsorsMapper {
        get { self[SponsorsMapperKey.self] }
        set { self[SponsorsMapperKey.self] = newValue }
    }
}
