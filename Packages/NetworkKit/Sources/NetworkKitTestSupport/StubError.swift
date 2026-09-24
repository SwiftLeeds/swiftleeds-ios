/// Why a test double could not build the value a test asked it for.
public enum StubError: Error, Equatable {
    /// The given text is not a URL.
    case couldNotParseURL

    /// `HTTPURLResponse` refused the URL and status code it was given.
    case couldNotBuildResponse
}
