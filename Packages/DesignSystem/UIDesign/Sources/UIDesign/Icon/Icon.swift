import SFSafeSymbols

/// A symbol identified by the role it plays, rather than by its shape.
///
/// Use a named icon, such as ``Icon/favorite``, so one meaning looks the same
/// everywhere. For a symbol this type doesn't name, create an icon from any
/// SF Symbol:
///
/// ```swift
/// import SFSafeSymbols
///
/// let icon = Icon(.figureRun)
/// ```
public struct Icon: Equatable, Hashable, Sendable {
    /// The SF Symbol's name, such as `star.fill`.
    fileprivate let systemName: String

    /// Creates an icon from an SF Symbol.
    ///
    /// A symbol newer than the deployment target doesn't compile.
    /// - Parameter symbol: The SF Symbol to show.
    public init(_ symbol: SFSymbol) {
        systemName = symbol.rawValue
    }
}

extension String {
    /// Creates the icon's SF Symbol name.
    /// - Parameter icon: The icon to read the name from.
    public init(_ icon: Icon) {
        self = icon.systemName
    }
}

// MARK: - Navigation

extension Icon {
    /// A left chevron, for the previous screen.
    public static let back = Icon(.chevronLeft)
    /// A right chevron, for the next screen.
    public static let forward = Icon(.chevronRight)
    /// An X, for dismissing a sheet or screen.
    public static let close = Icon(.xmark)
    /// Three dots, for further actions.
    public static let more = Icon(.ellipsis)
}

// MARK: - Actions

extension Icon {
    /// A box with an arrow out, for the share sheet.
    public static let share = Icon(.squareAndArrowUp)
    /// A plus, for creating an item.
    public static let add = Icon(.plus)
    /// A trash can, for removing an item.
    public static let delete = Icon(.trash)
    /// A pencil, for changing an item.
    public static let edit = Icon(.pencil)
    /// A magnifying glass, for a search field.
    public static let search = Icon(.magnifyingglass)
    /// Three narrowing lines, for a filter.
    public static let filter = Icon(.line3HorizontalDecrease)
    /// Arrows up and down, for a sort order.
    public static let sort = Icon(.arrowUpArrowDown)
    /// A circular arrow, for reloading.
    public static let refresh = Icon(.arrowClockwise)
    /// Two documents, for copying.
    public static let copy = Icon(.documentOnDocument)

    /// An outline star, for an item that is not a favorite yet.
    public static let favorite = Icon(.star)

    /// A solid star, for an item that is already a favorite.
    public static let favoriteFilled = Icon(.starFill)

    /// An arrow leaving a square, for an item that opens outside the app.
    ///
    /// Pair it with a link, never with navigation.
    public static let openExternal = Icon(.arrowUpRightSquare)
}

// MARK: - State

extension Icon {
    /// A check mark in a circle, for success.
    public static let success = Icon(.checkmarkCircle)
    /// An X in a circle, for a failure.
    public static let error = Icon(.xmarkCircle)
    /// An i in a circle, for more information.
    public static let info = Icon(.infoCircle)
    /// A padlock, for a locked item.
    public static let locked = Icon(.lock)
    /// Radio waves, for something happening now.
    public static let live = Icon(.dotRadiowavesLeftAndRight)

    /// Needs attention, though nothing has failed.
    public static let warning = Icon(.exclamationmarkTriangle)
}

// MARK: - Content

extension Icon {
    /// A calendar, for a date.
    public static let calendar = Icon(.calendar)
    /// A clock, for a time.
    public static let clock = Icon(.clock)
    /// A map pin, for a place.
    public static let location = Icon(.mappinAndEllipse)
    /// A person, for an attendee or speaker.
    public static let person = Icon(.person)
    /// A chain link, for a web address.
    public static let link = Icon(.link)
    /// A page of text, for a document.
    public static let document = Icon(.textDocument)
    /// A play button, for a video.
    public static let video = Icon(.playRectangle)
    /// A ticket, for the attendee's ticket.
    public static let ticket = Icon(.ticket)
}
