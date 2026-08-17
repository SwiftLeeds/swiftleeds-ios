import LogKit
import Testing

@Suite struct MessageTemplateTests {
    private let user = FieldName.positional(GapIndex(0), label: "user")
    private let token = FieldName.positional(GapIndex(1), label: nil)

    @Test func whenNoGaps_shouldBeTheLiteralText() {
        let sut: MessageTemplate = "Registering for push"

        #expect(sut.rendered(with: []) == "Registering for push")
    }

    @Test func whenGapHasField_shouldUseItsValue() {
        let sut = MessageTemplate(
            leadingText: "Signed in as ",
            gaps: [.init(placeholder: user, trailingText: " now")]
        )

        #expect(sut.rendered(with: [.open(user, "ada")]) == "Signed in as ada now")
    }

    @Test func whenGapHasNoField_shouldRenderMarker() {
        let sut = MessageTemplate(
            leadingText: "Signed in as ",
            gaps: [.init(placeholder: user, trailingText: "")]
        )

        #expect(sut.rendered(with: []) == "Signed in as <redacted>")
    }

    /// The rule the worked example exposed. `Log.unified` passes secrets through so it can put them
    /// in an interpolation the system redacts, which means a surviving secret would otherwise be
    /// rendered into the sentence, and the sentence is written as public.
    @Test func whenFieldIsSecret_shouldRenderMarkerEvenThoughFieldIsPresent() {
        let sut = MessageTemplate(
            leadingText: "Token ",
            gaps: [.init(placeholder: token, trailingText: " rejected")]
        )

        let rendered = sut.rendered(with: [.secret(token, "supersecret")])

        #expect(rendered == "Token <redacted> rejected")
        #expect(!rendered.contains("supersecret"))
    }

    @Test func whenSeveralGaps_shouldFillEachFromItsOwnField() {
        let sut = MessageTemplate(
            leadingText: "User ",
            gaps: [.init(placeholder: user, trailingText: " token "),
                   .init(placeholder: token, trailingText: "")]
        )

        let rendered = sut.rendered(with: [.open(user, "ada"), .secret(token, "abc")])

        #expect(rendered == "User ada token <redacted>")
    }

    /// An injected field cannot be mistaken for a gap, however it is named.
    @Test func whenInjectedFieldSharesGapLabel_shouldNotFillTheGap() {
        let sut = MessageTemplate(
            leadingText: "Signed in as ",
            gaps: [.init(placeholder: user, trailingText: "")]
        )

        #expect(sut.rendered(with: [.open("user", "impostor")]) == "Signed in as <redacted>")
    }
}
