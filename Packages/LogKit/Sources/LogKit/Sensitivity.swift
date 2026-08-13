/// How freely a logged value may travel.
///
/// Defined by meaning rather than by any one destination's privacy levels, so a
/// unified-log, file or remote destination can each honour it in its own terms.
public enum Sensitivity: Equatable, Hashable, Sendable {
    /// Safe to store or transmit anywhere.
    case open
    /// Correlatable but never readable. A destination that cannot hash must drop it.
    case hashed
    /// Never leaves the device.
    case secret
}
