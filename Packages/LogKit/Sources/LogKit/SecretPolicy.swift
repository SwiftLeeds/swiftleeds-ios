/// What a destination is trusted to do with a secret field.
///
/// The default is ``remove``, so a destination that says nothing never receives one.
public enum SecretPolicy: Equatable, Hashable, Sendable {
    /// Secret fields are dropped before the destination sees the event.
    case remove

    /// Secret fields are passed through, for a destination that redacts them itself.
    ///
    /// Only choose this where something downstream genuinely hides the value, as Apple's unified
    /// logging does for a `.sensitive` interpolation.
    case passThrough
}
