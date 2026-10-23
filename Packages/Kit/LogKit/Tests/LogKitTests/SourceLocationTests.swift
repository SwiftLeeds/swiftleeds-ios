import LogKit
import Testing

@Suite struct SourceLocationTests {
    @Test func whenCapturedHere_shouldRecordCallingFileAndFunction() {
        let sut = SourceLocation.here()

        #expect(sut.file.hasSuffix("SourceLocationTests.swift"))
        #expect(sut.function.hasPrefix("whenCapturedHere"))
        #expect(sut.line > 0)
    }
}
