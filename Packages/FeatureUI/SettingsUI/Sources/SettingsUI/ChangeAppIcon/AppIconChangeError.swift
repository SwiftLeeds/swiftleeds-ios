/// Why the app's icon did not change.
package enum AppIconChangeError: Error, Equatable, Sendable {
    /// This device does not let apps change their icon.
    case unsupported

    /// The system refused the change.
    case refused
}
