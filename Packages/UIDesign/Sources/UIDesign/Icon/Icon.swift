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

extension Icon {
    public static let back = Icon(.chevronLeft)
    public static let forward = Icon(.chevronRight)
    public static let close = Icon(.xmark)
    public static let more = Icon(.ellipsis)
}

// MARK: - Actions

extension Icon {
    public static let share = Icon(.squareAndArrowUp)
    public static let add = Icon(.plus)
    public static let delete = Icon(.trash)
    public static let edit = Icon(.pencil)
    public static let search = Icon(.magnifyingglass)
    public static let filter = Icon(.line3HorizontalDecrease)
    public static let sort = Icon(.arrowUpArrowDown)
    public static let refresh = Icon(.arrowClockwise)
    public static let copy = Icon(.documentOnDocument)

    /// An outline star, for an item that is not a favorite yet.
    public static let favorite = Icon(.star)

    /// A solid star, for an item that is already a favorite.
    public static let favoriteFilled = Icon(.starFill)

    /// Leaves the app. Pair it with a link, never with navigation.
    public static let openExternal = Icon(.arrowUpRightSquare)
}

// MARK: - State

extension Icon {
    public static let success = Icon(.checkmarkCircle)
    public static let error = Icon(.xmarkCircle)
    public static let info = Icon(.infoCircle)
    public static let locked = Icon(.lock)
    public static let live = Icon(.dotRadiowavesLeftAndRight)

    /// Needs attention, though nothing has failed.
    public static let warning = Icon(.exclamationmarkTriangle)
}

// MARK: - Content

extension Icon {
    public static let calendar = Icon(.calendar)
    public static let clock = Icon(.clock)
    public static let location = Icon(.mappinAndEllipse)
    public static let person = Icon(.person)
    public static let link = Icon(.link)
    public static let document = Icon(.textDocument)
    public static let video = Icon(.playRectangle)
    public static let ticket = Icon(.ticket)
}
