extension Optional {
    /// Returns the wrapped value.
    ///
    /// - Parameter error: The error to throw when this optional is `nil`.
    /// - Returns: The unwrapped value.
    /// - Throws: The given error when this optional is `nil`.
    func unwrap<Failure: Error>(orThrow error: @autoclosure () -> Failure) throws(Failure) -> Wrapped {
        guard let self else { throw error() }
        return self
    }
}
