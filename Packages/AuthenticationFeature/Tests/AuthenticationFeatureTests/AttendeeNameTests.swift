import AuthenticationFeature
import Testing

@Suite struct AttendeeNameTests {
    @Test func whenDescribed_shouldRedactValue() {
        let sut = AttendeeName("Ada Lovelace")
        #expect(!String(describing: sut).contains("Ada"))
    }
}
