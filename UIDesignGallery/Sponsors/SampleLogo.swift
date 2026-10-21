/// A placeholder for a company's logo, made up for the gallery.
///
/// Every field is display text rather than a domain value, for the reason
/// `SampleSession` gives. The symbol is a stand-in, because a real logo is an
/// image the backend supplies.
struct SampleLogo: Equatable, Hashable, Sendable {
    /// The name of the SF Symbol that stands in for the logo's mark.
    let symbol: String
}
