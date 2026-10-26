/// An error that no code under test catches by its type.
struct UnexpectedError: Error, Equatable, Hashable {}
