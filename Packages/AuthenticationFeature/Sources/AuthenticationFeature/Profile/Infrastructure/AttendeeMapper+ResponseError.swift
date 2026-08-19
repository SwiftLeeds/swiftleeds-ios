extension AttendeeMapper {
    package enum ResponseError: Error {
        case couldNotRead(any Error)
        case unauthorized
        case unexpectedStatus(Int)
    }
}

extension AttendeeFetchError {
    init(_ error: AttendeeMapper.ResponseError) {
        switch error {
        case .couldNotRead:
            self = .invalidResponse
        case .unauthorized:
            self = .unauthorized
        case .unexpectedStatus:
            self = .unknown
        }
    }
}
