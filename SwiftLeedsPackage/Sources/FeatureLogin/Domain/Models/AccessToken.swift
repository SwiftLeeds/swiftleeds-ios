struct AccessToken {
    private let rawValue: String

    var stringValue: String { rawValue }

    init(_ stringValue: String) {
        self.rawValue = stringValue
    }
}
