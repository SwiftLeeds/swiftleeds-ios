import SFSafeSymbols

/// A symbol identified by the role it plays, rather than by its shape.
///
/// Use a named icon, such as ``Icon/favorite``, so one meaning looks the same everywhere. For a
/// symbol this type doesn't name, create an icon from any SF Symbol:
///
/// ```swift
/// import SFSafeSymbols
///
/// let icon = Icon(.figureRun)
/// ```
public struct Icon: Equatable, Hashable, Sendable {
    // SFSymbol is a class with unchecked Sendable. Storing its name keeps this a value type.
    private let systemName: String

    /// Creates an icon from an SF Symbol.
    ///
    /// A symbol newer than the deployment target doesn't compile.
    public init(_ symbol: SFSymbol) {
        systemName = symbol.rawValue
    }
}

extension String {
    /// Creates the icon's SF Symbol name.
    public init(_ icon: Icon) {
        self = icon.name
    }
}

extension Icon {
    fileprivate var name: String { systemName }
}

// MARK: - Navigation

public extension Icon {
    static let back = Icon(.chevronLeft)
    static let forward = Icon(.chevronRight)
    static let close = Icon(.xmark)
    static let more = Icon(.ellipsis)
}

// MARK: - Actions

public extension Icon {
    static let share = Icon(.squareAndArrowUp)
    static let add = Icon(.plus)
    static let delete = Icon(.trash)
    static let edit = Icon(.pencil)
    static let search = Icon(.magnifyingglass)
    static let filter = Icon(.line3HorizontalDecrease)
    static let sort = Icon(.arrowUpArrowDown)
    static let refresh = Icon(.arrowClockwise)
    static let copy = Icon(.documentOnDocument)

    /// An outline star, for an item that is not a favorite yet.
    static let favorite = Icon(.star)

    /// A solid star, for an item that is already a favorite.
    static let favoriteFilled = Icon(.starFill)

    /// Leaves the app. Pair it with a link, never with navigation.
    static let openExternal = Icon(.arrowUpRightSquare)
}

// MARK: - State

public extension Icon {
    static let success = Icon(.checkmarkCircle)
    static let error = Icon(.xmarkCircle)
    static let info = Icon(.infoCircle)
    static let locked = Icon(.lock)
    static let live = Icon(.dotRadiowavesLeftAndRight)

    /// Needs attention, though nothing has failed.
    static let warning = Icon(.exclamationmarkTriangle)
}

// MARK: - Content

public extension Icon {
    static let calendar = Icon(.calendar)
    static let clock = Icon(.clock)
    static let location = Icon(.mappinAndEllipse)
    static let person = Icon(.person)
    static let link = Icon(.link)
    static let document = Icon(.textDocument)
    static let video = Icon(.playRectangle)
    static let ticket = Icon(.ticket)
}
