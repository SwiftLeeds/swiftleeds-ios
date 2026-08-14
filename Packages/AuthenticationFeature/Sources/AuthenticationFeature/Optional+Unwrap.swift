extension Optional {
    /// Returns the wrapped value, or throws the given error when `nil`.
    /// - Parameter error: The error to throw when this optional is `nil`.
    /// - Returns: The unwrapped value.
    func unwrap<Failure: Error>(orThrow error: @autoclosure () -> Failure) throws(Failure) -> Wrapped {
        guard let value = self else { throw error() }
        return value
    }
}
