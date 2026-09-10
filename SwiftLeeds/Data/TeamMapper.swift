import Dependencies
import Foundation
import NetworkKit

struct TeamMapper: Sendable {
    enum ResponseError: Error {
        case couldNotDecode(any Error)
        case unexpectedStatus(HTTPStatus)
    }

    var map: @Sendable (Data, HTTPURLResponse) throws(ResponseError) -> Team

    init(map: @escaping @Sendable (Data, HTTPURLResponse) throws(ResponseError) -> Team) {
        self.map = map
    }
}

extension TeamMapper {
    static let live = TeamMapper { data, response throws(ResponseError) in
        switch response.status {
        case .ok:
            do {
                return try JSONDecoder().decode(Team.self, from: data)
            } catch {
                throw .couldNotDecode(error)
            }
        default:
            throw .unexpectedStatus(response.status)
        }
    }
}

private enum TeamMapperKey: DependencyKey {
    static var liveValue: TeamMapper { .live }
    static var testValue: TeamMapper { liveValue }
}

extension DependencyValues {
    var teamMapper: TeamMapper {
        get { self[TeamMapperKey.self] }
        set { self[TeamMapperKey.self] = newValue }
    }
}
