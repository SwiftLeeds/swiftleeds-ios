extension AttendeeMapper {
    package enum ResponseError: Error {
        case couldNotDecode(any Error)
        case invalidField(AttendeeDTO.FieldError)
        case unauthorized
        case unexpectedStatus(Int)
    }
}

extension AttendeeFetchError {
    init(_ error: AttendeeMapper.ResponseError) {
        switch error {
        case .couldNotDecode:
            self = .invalidResponse
        case .invalidField:
            self = .invalidResponse
        case .unauthorized:
            self = .unauthorized
        case .unexpectedStatus:
            self = .unknown
        }
    }
}
