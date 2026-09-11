import Dependencies
import Foundation
import NetworkKit

/// Judges the response and decodes it, then hands the reader the translation.
package struct SponsorMapper: Sendable {
    package var map: @Sendable (Data, HTTPURLResponse) throws(ResponseError) -> [Sponsor]

    package init(map: @escaping @Sendable (Data, HTTPURLResponse) throws(ResponseError) -> [Sponsor]) {
        self.map = map
    }
}

extension SponsorMapper {
    package static let live = SponsorMapper { data, response throws(ResponseError) in
        @Dependency(\.sponsorsReader) var sponsorsReader

        switch response.status {
        case .ok:
            let list: SponsorListDTO
            do {
                list = try JSONDecoder().decode(SponsorListDTO.self, from: data)
            } catch {
                throw .couldNotDecode(error)
            }
            do throws(SponsorsReader.LevelError) {
                return try sponsorsReader.read(list)
            } catch {
                throw .unknownLevel(error)
            }
        default:
            throw .unexpectedStatus(response.status)
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
