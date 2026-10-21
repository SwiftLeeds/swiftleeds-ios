/// A job a sponsor is hiring for, made up for the gallery.
///
/// Every field is display text rather than a domain value, for the reason
/// `SampleSession` gives.
struct SampleJob: Identifiable, Equatable, Hashable, Sendable {
    /// Tells one sample job from another.
    var id: String { title }

    /// What the job is called.
    let title: String

    /// The place the job is based.
    let location: String

    /// The page that advertises the job, which opens outside the app.
    let link: SampleLink
}
