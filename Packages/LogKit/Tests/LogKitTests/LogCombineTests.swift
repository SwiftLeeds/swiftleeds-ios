import LogKit
import Testing

@Suite struct LogCombineTests {
    @Test func whenCombiningTwoLogs_shouldWriteToBoth() {
        let first = LogRecorder()
        let second = LogRecorder()
        let sut = Log.combine([first.log, second.log])

        sut.write(.stub("shared"))

        #expect(first.events.map(\.message) == ["shared"])
        #expect(second.events.map(\.message) == ["shared"])
    }

    @Test func whenCombiningNoLogs_shouldMatchNone() {
        let viaEmpty = LogRecorder()
        let viaNone = LogRecorder()

        Log.combine([.combine([]), viaEmpty.log]).write(.stub("empty"))
        Log.combine([.none, viaNone.log]).write(.stub("empty"))

        #expect(viaEmpty.events == viaNone.events)
    }

    @Test func whenSameLogAppearsTwice_shouldWriteTwice() {
        let recorder = LogRecorder()
        let sut = Log.combine([recorder.log, recorder.log])

        sut.write(.stub("twice"))

        #expect(recorder.events.count == 2)
    }

    @Test func whenNoneIsOnTheLeft_shouldMatchLogAlone() {
        let combined = LogRecorder()
        let alone = LogRecorder()

        Log.combine([.none, combined.log]).write(.stub("identity"))
        alone.log.write(.stub("identity"))

        #expect(combined.events == alone.events)
    }

    @Test func whenNoneIsOnTheRight_shouldMatchLogAlone() {
        let combined = LogRecorder()
        let alone = LogRecorder()

        Log.combine([combined.log, .none]).write(.stub("identity"))
        alone.log.write(.stub("identity"))

        #expect(combined.events == alone.events)
    }

    @Test func whenGroupedEitherWay_shouldProduceSameEvents() {
        let left = LogRecorder()
        let right = LogRecorder()

        let leftGrouped = Log.combine([Log.combine([left.log, left.log]), left.log])
        let rightGrouped = Log.combine([right.log, Log.combine([right.log, right.log])])

        leftGrouped.write(.stub("associative"))
        rightGrouped.write(.stub("associative"))

        #expect(left.events == right.events)
    }

    @Test func whenCombinedWithAnother_shouldWriteToBoth() {
        let first = LogRecorder()
        let second = LogRecorder()
        let sut = first.log.combined(with: second.log)

        sut.write(.stub("pair"))

        #expect(first.events.count == 1)
        #expect(second.events.count == 1)
    }
}
