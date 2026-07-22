#warning("Move to some `SharedKernel` target")

import Foundation

public struct Session: Equatable, Hashable, Sendable {
    public let expiresAt: Date

    public init(expiresAt: Date) {
        self.expiresAt = expiresAt
    }
}
