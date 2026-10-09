/// The state the sign-in screen opens in.
///
/// The raw value is what the `-signin` launch argument accepts. Every field
/// is display text rather than a domain value, for the reason `SampleSession`
/// gives.
enum SignInState: String, CaseIterable, Equatable, Hashable {
    /// Nothing typed yet.
    case blank

    /// Both fields hold a sample attendee's ticket details.
    case filled

    /// The email address the screen opens with.
    var email: String {
        switch self {
        case .blank: ""
        case .filled: SampleAttendee.signedIn.email
        }
    }

    /// The ticket reference the screen opens with.
    var ticketReference: String {
        switch self {
        case .blank: ""
        case .filled: "SLDS-7"
        }
    }
}
