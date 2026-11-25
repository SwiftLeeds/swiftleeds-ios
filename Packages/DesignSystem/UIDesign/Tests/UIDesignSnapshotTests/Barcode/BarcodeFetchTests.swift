#if os(iOS)
import SwiftUI
import Testing
import UIDesign

@MainActor
@Suite(.serialized, .timeLimit(.minutes(3)))
struct BarcodeFetchTests {
    /// A style that draws a word beside the barcode's content.
    private struct StyledBarcodeStyle: BarcodeStyle {
        /// Creates a view that represents the body of a barcode.
        ///
        /// - Parameter configuration: The properties of the barcode.
        /// - Returns: A view that represents the body of a barcode.
        @MainActor
        func makeBody(configuration: Configuration) -> some View {
            HStack {
                Text(BarcodeFetchTests.styleWord)
                configuration.content
            }
        }
    }

    /// A barcode whose URL changes from one address to another once the stub reaches a point.
    private struct URLChangingBarcode: View {
        /// The point in the first request at which the URL changes.
        enum Trigger {
            /// The stub has answered the first request.
            case answered

            /// The stub has recorded the first request.
            case requested
        }

        /// How long the wrapper waits between looks at the stub.
        private static let pollPause = Duration.milliseconds(5)

        /// The stub that stands in for the loader.
        let stub: BarcodeLoaderStub

        /// The address the barcode starts with.
        let first: URL

        /// The address the barcode changes to.
        let second: URL

        /// The point in the first request at which the URL changes.
        let trigger: Trigger

        /// A pause after the trigger and before the change, or `nil` for none.
        let pause: Duration?

        /// The address the barcode loads now.
        @State private var url: URL

        /// Creates a barcode that changes its URL.
        ///
        /// - Parameters:
        ///   - stub: The stub that stands in for the loader.
        ///   - first: The address the barcode starts with.
        ///   - second: The address the barcode changes to.
        ///   - trigger: The point in the first request at which the URL changes.
        ///   - pause: A pause after the trigger and before the change, or `nil` for none.
        init(stub: BarcodeLoaderStub, first: URL, second: URL, trigger: Trigger, pause: Duration? = nil) {
            self.stub = stub
            self.first = first
            self.second = second
            self.trigger = trigger
            self.pause = pause
            _url = State(initialValue: first)
        }

        var body: some View {
            BarcodeFetchTests.barcode(url: url, stub: stub)
                .task { try? await change() }
        }

        /// Waits for the trigger, then pauses, then changes the URL.
        ///
        /// - Throws: `CancellationError` when the view goes away while it waits.
        private func change() async throws {
            let end = ContinuousClock.now + BarcodeFetchTests.deadline
            while await !isTriggered() {
                guard ContinuousClock.now < end else {
                    Issue.record("The stub never reached the trigger for \(first).")
                    return
                }
                try await Task.sleep(for: Self.pollPause)
            }
            if let pause { try await Task.sleep(for: pause) }
            url = second
        }

        /// Returns whether the stub has reached the trigger for the first address.
        ///
        /// - Returns: `true` when the trigger has happened.
        private func isTriggered() async -> Bool {
            switch trigger {
            case .answered: await stub.hasAnswered(first)
            case .requested: await stub.hasRequested(first)
            }
        }
    }

    /// The label the caller gives the barcode.
    private static let label = "Ticket QR code"

    /// The words the placeholder draws.
    private static let placeholderText = "Loading the code"

    /// The words the fallback draws.
    private static let fallbackText = "No code to show"

    /// The word the test style draws beside the content.
    private static let styleWord = "Styled"

    /// The text the code carries, made up.
    private static let text = "ti_ExampleTicket0000000000"

    /// The pause that lets a code, once answered, reach the phase before the URL changes.
    private static let mainActorHop = Duration.milliseconds(20)

    /// How long a hosted view settles before its elements are read.
    private static let settleTime = Duration.milliseconds(300)

    /// How long a hosted view settles once its condition holds, before its elements are read.
    private static let shortSettleTime = Duration.milliseconds(100)

    /// The longest a wait for a condition may last.
    private static let deadline = Duration.seconds(2)

    /// A phase that holds the marks of a made-up code.
    ///
    /// - Throws: When the code, its image or its marks cannot be made.
    private static var successPhase: BarcodeLoadingPhase {
        get throws {
            .success(try SuppliedBarcodeImage(LightBlueCodeImage.make(carrying: text)))
        }
    }

    /// Returns a barcode in the given phase, with a placeholder and a fallback of its own.
    ///
    /// - Parameter phase: The phase of the load to draw.
    /// - Returns: The barcode, drawn in the test style.
    private static func barcode(in phase: BarcodeLoadingPhase) -> some View {
        Barcode(
            phase: phase,
            label: Text(label),
            placeholder: { Text(placeholderText) },
            fallback: { Text(fallbackText) },
        )
        .barcodeStyle(StyledBarcodeStyle())
    }

    /// Returns a barcode that loads a URL through a stub, drawn in the test style.
    ///
    /// - Parameters:
    ///   - url: The address to load, or `nil` for none.
    ///   - stub: The stub that stands in for the loader.
    /// - Returns: The barcode.
    private static func barcode(url: URL?, stub: BarcodeLoaderStub) -> some View {
        Barcode(
            url: url,
            label: Text(label),
            placeholder: { Text(placeholderText) },
            fallback: { Text(fallbackText) },
        )
        .barcodeStyle(StyledBarcodeStyle())
        .environment(\.barcodeLoader, stub.loader)
    }

    /// Returns a made-up address on example.com.
    ///
    /// - Parameter name: The name of the image.
    /// - Returns: The address.
    /// - Throws: When the text is not a URL.
    private static func address(_ name: String) throws -> URL {
        try #require(URL(string: "https://codes.example.com/\(name).png"))
    }

    /// Returns a stub that answers each address as given.
    ///
    /// - Parameter answers: What the stub does for each address.
    /// - Returns: The stub, with a made-up code to return.
    /// - Throws: When the code cannot be made.
    private static func stub(answers: [URL: BarcodeLoaderStub.Answer]) throws -> BarcodeLoaderStub {
        BarcodeLoaderStub(
            code: try SuppliedBarcodeImage(LightBlueCodeImage.make(carrying: text)),
            answers: answers,
        )
    }

    /// Reads the elements a hosted view exposes once its loads have had time to end.
    ///
    /// - Parameter view: The view to read.
    /// - Returns: The elements, in the order the hierarchy lists them.
    /// - Throws: When accessibility cannot be turned on.
    private static func elements(of view: some View) async throws -> [AccessibilityTree.Element] {
        try await AccessibilityTree.elements(of: view, settle: settleTime)
    }

    /// Reads the elements a hosted view exposes once a request for a URL has been recorded and, when
    /// asked, the first URL's answer has arrived.
    ///
    /// Records an issue when the condition does not hold before the deadline.
    ///
    /// - Parameters:
    ///   - view: The view to read.
    ///   - stub: The stub that stands in for the loader.
    ///   - requested: The URL whose request must be recorded.
    ///   - answered: The URL whose answer must be recorded, or `nil` for none.
    /// - Returns: The elements, in the order the hierarchy lists them.
    /// - Throws: When accessibility cannot be turned on.
    private static func elements(
        of view: some View,
        stub: BarcodeLoaderStub,
        requested: URL,
        answered: URL? = nil,
    ) async throws -> [AccessibilityTree.Element] {
        let result = try await AccessibilityTree.elements(
            of: view,
            until: {
                guard await stub.hasRequested(requested) else { return false }
                guard let answered else { return true }
                return await stub.hasAnswered(answered)
            },
            deadline: deadline,
            settle: shortSettleTime,
        )
        if !result.conditionMet { Issue.record("The stub did not reach the condition in time.") }
        return result.elements
    }

    @Test
    func whenLoadSucceeds_shouldExposeImageElementWithLabel() async throws {
        let url = try Self.address("a")
        let stub = try Self.stub(answers: [url: .code])
        let sut = Self.barcode(url: url, stub: stub)
        let elements = try await Self.elements(of: sut)
        let image = try #require(elements.first { $0.label == Self.label })
        #expect(image.traits.contains(.image))
        #expect(elements.map(\.label) == [Self.styleWord, Self.label])
    }

    @Test
    func whenLoadFails_shouldExposeOnlyFallbackElement() async throws {
        let url = try Self.address("a")
        let stub = try Self.stub(answers: [url: .failure])
        let sut = Self.barcode(url: url, stub: stub)
        let labels = try await Self.elements(of: sut).map(\.label)
        #expect(labels == [Self.fallbackText])
    }

    @Test
    func whenLoadNeverReturns_shouldExposeOnlyPlaceholderElement() async throws {
        let url = try Self.address("a")
        let stub = try Self.stub(answers: [url: .neverReturns])
        let sut = Self.barcode(url: url, stub: stub)
        let labels = try await Self.elements(of: sut).map(\.label)
        #expect(labels == [Self.placeholderText])
    }

    @Test
    func whenURLIsNil_shouldExposeOnlyFallbackElementAndSendNoRequest() async throws {
        let stub = try Self.stub(answers: [:])
        let sut = Self.barcode(url: nil, stub: stub)
        let labels = try await Self.elements(of: sut).map(\.label)
        #expect(labels == [Self.fallbackText])
        #expect(await stub.requests.isEmpty)
    }

    @Test
    func whenURLChangesAfterCodeLoaded_shouldExposeOnlyPlaceholderElement() async throws {
        let first = try Self.address("a")
        let second = try Self.address("b")
        let stub = try Self.stub(answers: [first: .code, second: .neverReturns])
        let sut = URLChangingBarcode(
            stub: stub,
            first: first,
            second: second,
            trigger: .answered,
            pause: Self.mainActorHop,
        )
        let labels = try await Self.elements(of: sut, stub: stub, requested: second).map(\.label)
        #expect(labels == [Self.placeholderText])
        #expect(await stub.requests == [first, second])
    }

    @Test
    func whenURLChangesBeforeLateCodeArrives_shouldExposeOnlyPlaceholderElement() async throws {
        let first = try Self.address("a")
        let second = try Self.address("b")
        let stub = try Self.stub(answers: [first: .lateCode, second: .neverReturns])
        let sut = URLChangingBarcode(stub: stub, first: first, second: second, trigger: .requested)
        let labels = try await Self.elements(
            of: sut,
            stub: stub,
            requested: second,
            answered: first,
        ).map(\.label)
        #expect(labels == [Self.placeholderText])
        #expect(await stub.requests == [first, second])
        #expect(await stub.hasAnswered(first))
    }

    @Test
    func whenURLChangesBeforeLateFailureArrives_shouldExposeOnlyPlaceholderElement() async throws {
        let first = try Self.address("a")
        let second = try Self.address("b")
        let stub = try Self.stub(answers: [first: .lateFailure, second: .neverReturns])
        let sut = URLChangingBarcode(stub: stub, first: first, second: second, trigger: .requested)
        let labels = try await Self.elements(
            of: sut,
            stub: stub,
            requested: second,
            answered: first,
        ).map(\.label)
        #expect(labels == [Self.placeholderText])
        #expect(await stub.requests == [first, second])
        #expect(await stub.hasAnswered(first))
    }

    @Test
    func whenPhaseSucceeds_shouldExposeImageElementWithLabel() throws {
        let sut = Self.barcode(in: try Self.successPhase)
        let elements = try AccessibilityTree.elements(of: sut)
        let image = try #require(elements.first { $0.label == Self.label })
        #expect(image.traits.contains(.image))
        #expect(elements.count { $0.label == Self.label } == 1)
    }

    @Test
    func whenPhaseSucceeds_shouldDrawStyle() throws {
        let sut = Self.barcode(in: try Self.successPhase)
        let labels = try AccessibilityTree.elements(of: sut).map(\.label)
        #expect(labels.contains(Self.styleWord), "\(labels) does not hold the style's word")
    }

    @Test
    func whenPhaseFails_shouldExposeOnlyFallbackElement() throws {
        let sut = Self.barcode(in: .failure)
        let labels = try AccessibilityTree.elements(of: sut).map(\.label)
        #expect(labels == [Self.fallbackText])
    }

    @Test
    func whenPhaseIsEmpty_shouldExposeOnlyPlaceholderElement() throws {
        let sut = Self.barcode(in: .empty)
        let labels = try AccessibilityTree.elements(of: sut).map(\.label)
        #expect(labels == [Self.placeholderText])
    }
}
#endif
