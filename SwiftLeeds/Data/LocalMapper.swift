import Dependencies
import Foundation
import NetworkKit

struct LocalMapper: Sendable {
    enum ResponseError: Error {
        case couldNotDecode(any Error)
        case unexpectedStatus(HTTPStatus)
    }

    var map: @Sendable (Data, HTTPURLResponse) throws(ResponseError) -> Local

    init(map: @escaping @Sendable (Data, HTTPURLResponse) throws(ResponseError) -> Local) {
        self.map = map
    }
}

extension LocalMapper {
    static let live = LocalMapper { data, response throws(ResponseError) in
        switch response.status {
        case .ok:
            do {
                return try JSONDecoder().decode(Local.self, from: data)
            } catch {
                throw .couldNotDecode(error)
            }
        default:
            throw .unexpectedStatus(response.status)
        }
    }
}

private enum LocalMapperKey: DependencyKey {
    static var liveValue: LocalMapper { .live }
    static var testValue: LocalMapper { liveValue }
}

extension DependencyValues {
    var localMapper: LocalMapper {
        get { self[LocalMapperKey.self] }
        set { self[LocalMapperKey.self] = newValue }
    }
}
