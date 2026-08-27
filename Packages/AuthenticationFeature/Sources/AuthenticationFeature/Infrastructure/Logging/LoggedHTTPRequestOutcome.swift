import Foundation
import LogKit

struct LoggedHTTPRequestOutcome {
    let level: LogLevel
    let message: LogMessage

    // A response runs on every request in the app, so it records at the level the platform drops
    // unless someone is watching. The status is data, not severity: whoever reads the response
    // decides whether a 500 is a failure.
    static func success(request: URLRequest, status: HTTPStatus) -> LoggedHTTPRequestOutcome {
        LoggedHTTPRequestOutcome(
            level: .debug,
            message: """
            A response arrived: \
            \(request.loggedSummary, name: "request", privacy: .open), \
            \(Int(status.code), name: "statusCode", privacy: .open)
            """
        )
    }

    static func failure(request: URLRequest, error: any Error) -> LoggedHTTPRequestOutcome {
        let reason = Reason(error)
        return LoggedHTTPRequestOutcome(
            level: reason.level,
            message: """
            A request did not reach the server: \
            \(request.loggedSummary, name: "request", privacy: .open), \
            \(reason.name, name: "reason", privacy: .open)
            """
        )
    }
}

extension LoggedHTTPRequestOutcome {
    // `URLError` describes itself by dumping its `userInfo`, which names the URL it failed on with
    // the query attached. Naming the code instead keeps a caller's credentials out of the log.
    private struct Reason {
        let name: String
        let level: LogLevel

        init(_ error: any Error) {
            guard let error = error as? URLError else {
                self.name = String(logDescribing: error)
                self.level = .error
                return
            }
            self.name = Self.name(for: error.code)
            self.level = Self.level(for: error.code)
        }

        // Cancelling is ordinary control flow, such as leaving a screen while it loads. An offline
        // device is expected and the user can retry, which is the level the outcome seams already
        // give it. Anything else is a surprise worth acting on.
        private static func level(for code: URLError.Code) -> LogLevel {
            switch code {
            case .cancelled:
                .debug
            case .notConnectedToInternet:
                .notice
            case .networkConnectionLost:
                .notice
            case .timedOut:
                .notice
            case .dataNotAllowed:
                .notice
            case .internationalRoamingOff:
                .notice
            default:
                .error
            }
        }

        // `URLError.Code` is a struct of static members rather than an enum, so it has no name of
        // its own. The codes a request can realistically fail with are named here; the rest keep
        // their number, which still identifies the failure exactly.
        private static func name(for code: URLError.Code) -> String {
            switch code {
            case .cancelled:
                "cancelled"
            case .notConnectedToInternet:
                "notConnectedToInternet"
            case .networkConnectionLost:
                "networkConnectionLost"
            case .timedOut:
                "timedOut"
            case .dataNotAllowed:
                "dataNotAllowed"
            case .internationalRoamingOff:
                "internationalRoamingOff"
            case .cannotFindHost:
                "cannotFindHost"
            case .cannotConnectToHost:
                "cannotConnectToHost"
            case .dnsLookupFailed:
                "dnsLookupFailed"
            case .badServerResponse:
                "badServerResponse"
            case .secureConnectionFailed:
                "secureConnectionFailed"
            case .serverCertificateUntrusted:
                "serverCertificateUntrusted"
            default:
                "URLError \(code.rawValue)"
            }
        }
    }
}

extension URLRequest {
    // Method and path only. A query can carry credentials and headers carry the bearer token, so
    // neither belongs in a log.
    fileprivate var loggedSummary: String {
        [httpMethod, url?.path(percentEncoded: false)]
            .compactMap { $0 }
            .joined(separator: " ")
    }
}
