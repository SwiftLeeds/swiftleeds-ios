import Dependencies
import Foundation
import NetworkKit

package struct SponsorMapper: Sendable {
    package var map: @Sendable (Data, HTTPURLResponse) throws(ResponseError) -> [Sponsor]

    package init(map: @escaping @Sendable (Data, HTTPURLResponse) throws(ResponseError) -> [Sponsor]) {
        self.map = map
    }
}

extension SponsorMapper {
    package static let live = SponsorMapper { data, response throws(ResponseError) in
        guard response.status == .ok else {
            throw .unexpectedStatus(response.status)
        }

        let list: SponsorListDTO
        do {
            list = try JSONDecoder().decode(SponsorListDTO.self, from: data)
        } catch {
            throw .couldNotDecode(error)
        }

        do throws(SponsorListDTO.LevelError) {
            return try list.sponsors()
        } catch {
            throw .unknownLevel(error)
        }
    }
}

private enum SponsorMapperKey: DependencyKey {
    static var liveValue: SponsorMapper { .live }
    static var testValue: SponsorMapper { liveValue }
}

extension DependencyValues {
    package var sponsorMapper: SponsorMapper {
        get { self[SponsorMapperKey.self] }
        set { self[SponsorMapperKey.self] = newValue }
    }
}
