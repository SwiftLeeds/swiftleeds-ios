import LogKit
import Testing

@Suite struct LogValueRenderingTests {
    @Test func whenRenderingScalars_shouldUseTheirTextForm() {
        #expect(LogValue.string("ada").rendered == "ada")
        #expect(LogValue.integer(200).rendered == "200")
        #expect(LogValue.boolean(true).rendered == "true")
    }

    @Test func whenRenderingArray_shouldKeepElementOrder() {
        #expect(LogValue.array(["a", "b", "c"]).rendered == "[a, b, c]")
    }

    @Test func whenRenderingDictionary_shouldSortKeysForStableOutput() {
        let sut = LogValue.dictionary(["status": 200, "again": false])

        #expect(sut.rendered == "[again: false, status: 200]")
    }
}
