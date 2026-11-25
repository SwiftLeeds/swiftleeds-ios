#if os(iOS)
import Foundation
import Synchronization
import UIDesign

/// A stand-in for the loader that records each request and each answer, and answers per URL.
actor BarcodeLoaderStub {
    /// What the spy does when a URL is requested.
    enum Answer: Equatable, Sendable {
        /// Returns the code at once.
        case code

        /// Throws at once.
        case failure

        /// Waits until the task is cancelled, then throws.
        case neverReturns

        /// Returns the code after a pause that cancellation cannot cut short.
        case lateCode

        /// Throws after a pause that cancellation cannot cut short.
        case lateFailure
    }

    /// One thing the spy saw or did.
    enum Event: Equatable, Sendable {
        /// The loader was asked for this URL.
        case requested(URL)

        /// The spy gave an answer for this URL, a code or a failure.
        case answered(URL)
    }

    /// Waits for the task that holds it to be cancelled, without missing a cancellation that comes first.
    private final class CancellationWait: Sendable {
        /// What the wait knows.
        private struct State {
            /// Whether the task was cancelled.
            var cancelled = false

            /// The continuation to resume on cancellation, once the wait has stored it.
            var continuation: CheckedContinuation<Void, Never>?
        }

        /// The state, shared by the waiting task and the cancellation handler.
        private let state = Mutex(State())

        /// Returns when the current task is cancelled.
        func untilCancelled() async {
            await withTaskCancellationHandler {
                await withCheckedContinuation { continuation in
                    let alreadyCancelled = state.withLock { state -> Bool in
                        state.continuation = continuation
                        return state.cancelled
                    }
                    if alreadyCancelled { resume() }
                }
            } onCancel: {
                state.withLock { $0.cancelled = true }
                resume()
            }
        }

        /// Resumes the stored continuation, if there is one, and forgets it.
        private func resume() {
            let stored = state.withLock { state -> CheckedContinuation<Void, Never>? in
                defer { state.continuation = nil }
                return state.continuation
            }
            stored?.resume()
        }
    }

    /// How long a late answer waits.
    private static let latePause = Duration.milliseconds(100)

    /// The code the spy returns.
    private let code: SuppliedBarcodeImage

    /// What the spy does for each URL.
    private let answers: [URL: Answer]

    /// What the spy saw and did, in order.
    private(set) var events: [Event] = []

    /// The loader that sends each request to this spy.
    nonisolated var loader: BarcodeLoader {
        BarcodeLoader { (request: URLRequest) async throws(BarcodeLoader.LoadingError) -> SuppliedBarcodeImage in
            try await self.answer(request)
        }
    }

    /// The URLs requested, in order.
    var requests: [URL] {
        events.compactMap { event in
            guard case .requested(let url) = event else { return nil }
            return url
        }
    }

    /// Creates a spy.
    ///
    /// - Parameters:
    ///   - code: The code the spy returns when an answer is a code.
    ///   - answers: What the spy does for each URL. A URL left out fails at once.
    init(code: SuppliedBarcodeImage, answers: [URL: Answer]) {
        self.code = code
        self.answers = answers
    }

    /// Returns whether the loader was asked for a URL.
    ///
    /// - Parameter url: The URL to look for.
    /// - Returns: `true` when a request for `url` was recorded.
    func hasRequested(_ url: URL) -> Bool {
        events.contains(.requested(url))
    }

    /// Returns whether the spy gave an answer for a URL.
    ///
    /// - Parameter url: The URL to look for.
    /// - Returns: `true` when an answer for `url` was recorded.
    func hasAnswered(_ url: URL) -> Bool {
        events.contains(.answered(url))
    }

    /// Records a request and answers it as planned.
    ///
    /// - Parameter request: The request to answer.
    /// - Returns: The code, when the plan for its URL is a code.
    /// - Throws: ``BarcodeLoader/LoadingError/transportFailed`` when the plan is a failure or a cancelled wait.
    private func answer(
        _ request: URLRequest
    ) async throws(BarcodeLoader.LoadingError) -> SuppliedBarcodeImage {
        guard let url = request.url else { throw .transportFailed }
        events.append(.requested(url))
        switch answers[url] ?? .failure {
        case .code:
            events.append(.answered(url))
            return code

        case .failure:
            events.append(.answered(url))
            throw .transportFailed

        case .neverReturns:
            await CancellationWait().untilCancelled()
            throw .transportFailed

        case .lateCode:
            await pause()
            events.append(.answered(url))
            return code

        case .lateFailure:
            await pause()
            events.append(.answered(url))
            throw .transportFailed
        }
    }

    /// Waits for the late pause, in a task that cancellation does not reach.
    private func pause() async {
        await Task.detached { try? await Task.sleep(for: Self.latePause) }.value
    }
}
#endif
