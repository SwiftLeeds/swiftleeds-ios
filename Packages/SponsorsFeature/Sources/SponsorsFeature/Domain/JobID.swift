import Foundation

public struct JobID: Equatable, Hashable, Sendable {
    fileprivate let storage: UUID

    public init(_ value: UUID) {
        self.storage = value
    }
}
