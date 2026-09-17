import Foundation

public struct LocationCategoryID: Equatable, Hashable, Sendable {
    fileprivate let storage: UUID

    public init(_ value: UUID) {
        self.storage = value
    }
}
