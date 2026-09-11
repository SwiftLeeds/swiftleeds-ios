import NetworkKit

extension SponsorMapper {
    package enum ResponseError: Error {
        case couldNotDecode(any Error)
        case unknownLevel(SponsorListDTO.LevelError)
        case unexpectedStatus(HTTPStatus)
    }
}

extension SponsorFetchError {
    init(_ error: SponsorMapper.ResponseError) {
        switch error {
        case .couldNotDecode:
            self = .invalidResponse
        case .unknownLevel:
            self = .invalidResponse
        case .unexpectedStatus:
            self = .unknown
        }
    }
}
