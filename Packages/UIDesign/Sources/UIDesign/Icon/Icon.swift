import SFSafeSymbols

/// A symbol, named for the role it plays rather than for its shape.
///
/// The named icons below are the vocabulary. Reach for one of those first, so the same idea looks
/// the same everywhere. For a role the vocabulary does not name, build one from any SF Symbol:
///
/// ```swift
/// import SFSafeSymbols
///
/// let icon = Icon(.figureRun)
/// ```
public struct Icon: Equatable, Hashable, Sendable {
    // The name, not the SFSymbol. SFSymbol is a class marked @unchecked Sendable, and storing it
    // would make this a reference wrapper resting on someone else's claim. The version check that
    // makes the library worth having still happens, at the call site below.
    private let systemName: String

    /// Creates an icon for any SF Symbol.
    ///
    /// - Parameter symbol: The symbol to draw. It will not compile if the symbol is newer than
    ///   the deployment target.
    public init(_ symbol: SFSymbol) {
        systemName = symbol.rawValue
    }
}

extension String {
    /// The icon's SF Symbol name, for an API that takes one.
    public init(_ icon: Icon) {
        self = icon.name
    }
}

extension Icon {
    fileprivate var name: String { systemName }
}

// MARK: - Navigation

public extension Icon {
    /// Goes back to the previous screen.
    static let back = Icon(.chevronLeft)

    /// Goes forward, or opens the row's detail.
    static let forward = Icon(.chevronRight)

    /// Closes a sheet or dismisses a message.
    static let close = Icon(.xmark)

    /// Opens a menu of further actions.
    static let more = Icon(.ellipsis)
}

// MARK: - Actions

public extension Icon {
    /// Shares the item with another app or person.
    static let share = Icon(.squareAndArrowUp)

    /// Marks the item as a favourite.
    static let favorite = Icon(.star)

    /// The item is already a favourite.
    static let favoriteFilled = Icon(.starFill)

    /// Creates a new item.
    static let add = Icon(.plus)

    /// Removes the item for good.
    static let delete = Icon(.trash)

    /// Changes the item.
    static let edit = Icon(.pencil)

    /// Searches.
    static let search = Icon(.magnifyingglass)

    /// Narrows what the list shows.
    static let filter = Icon(.line3HorizontalDecrease)

    /// Changes the order of the list.
    static let sort = Icon(.arrowUpArrowDown)

    /// Fetches the content again.
    static let refresh = Icon(.arrowClockwise)

    /// Copies the value to the clipboard.
    static let copy = Icon(.documentOnDocument)

    /// Opens something outside the app. Pair it with a link, never with navigation.
    static let openExternal = Icon(.arrowUpRightSquare)
}

// MARK: - State

public extension Icon {
    /// It worked, or it is confirmed.
    static let success = Icon(.checkmarkCircle)

    /// It needs attention, but nothing is broken.
    static let warning = Icon(.exclamationmarkTriangle)

    /// It failed.
    static let error = Icon(.xmarkCircle)

    /// Neutral information.
    static let info = Icon(.infoCircle)

    /// The person cannot reach this yet.
    static let locked = Icon(.lock)

    /// It is happening right now.
    static let live = Icon(.dotRadiowavesLeftAndRight)
}

// MARK: - Content

public extension Icon {
    /// A date, or a day in the schedule.
    static let calendar = Icon(.calendar)

    /// A time, or how long something lasts.
    static let clock = Icon(.clock)

    /// A place.
    static let location = Icon(.mappinAndEllipse)

    /// A person.
    static let person = Icon(.person)

    /// A web address.
    static let link = Icon(.link)

    /// A document, such as a PDF.
    static let document = Icon(.textDocument)

    /// A recording.
    static let video = Icon(.playRectangle)

    /// A ticket.
    static let ticket = Icon(.ticket)
}
