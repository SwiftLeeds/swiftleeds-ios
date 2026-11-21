#if os(iOS)
import SFSafeSymbols
import SwiftUI
import Testing
import UIDesign

@MainActor
@Suite
struct NoticeAccessibilityTests {
    /// A notice style that draws the icon from the configuration, and beside it the same symbol outside it.
    private struct IconBesideOutsideIconStyle: NoticeStyle {
        func makeBody(configuration: Configuration) -> some View {
            HStack {
                configuration.icon
                Image(icon: Icon(.wifiSlash))
            }
        }
    }

    /// A notice style that draws the title and the description with no grouping.
    private struct UngroupedNoticeStyle: NoticeStyle {
        func makeBody(configuration: Configuration) -> some View {
            VStack(alignment: .leading) {
                configuration.title
                configuration.description
                configuration.actions
            }
        }
    }

    /// The title every test gives its notice.
    private static let title = "You're offline"

    /// The description every test gives its notice.
    private static let description = "The schedule shows what was saved. It updates when you reconnect."

    /// The label of the one element that reads the title and the description together.
    private static let groupedLabel = "\(title), \(description)"

    /// A notice with a title, a description and one action, built through the convenience initializer.
    private var notice: some View {
        Notice(Self.title, icon: Icon(.wifiSlash), description: Text(Self.description)) {
            Button("Try Again") {}
        }
    }

    /// The documented call site: the notice in a list section, with a borderless button.
    private var noticeInList: some View {
        List {
            Section {
                Notice(Self.title, icon: Icon(.wifiSlash), description: Text(Self.description)) {
                    Button("Try Again") {}
                        .buttonStyle(.borderless)
                }
            }
        }
    }

    /// Returns whether any element's label contains the title.
    ///
    /// - Parameter notice: The notice to read.
    /// - Returns: Whether an element's label contains the title.
    /// - Throws: ``AccessibilityTree/SwitchOnError`` when accessibility cannot be turned on.
    private func readsTitle(of notice: some View) throws -> Bool {
        let labels = try AccessibilityTree.elements(of: notice).compactMap(\.label)
        return labels.contains { $0.contains(Self.title) }
    }

    @Test
    func whenTitleIsLocalizedStringKey_shouldReadTitleInElementLabel() throws {
        let notice = Notice("You're offline", icon: Icon(.wifiSlash), description: Text(Self.description)) {
            Button("Try Again") {}
        }
        #expect(try readsTitle(of: notice))
    }

    @Test
    func whenTitleIsLocalizedStringResource_shouldReadTitleInElementLabel() throws {
        let title = LocalizedStringResource("You're offline")
        let notice = Notice(title, icon: Icon(.wifiSlash), description: Text(Self.description)) {
            Button("Try Again") {}
        }
        #expect(try readsTitle(of: notice))
    }

    @Test
    func whenTitleIsString_shouldReadTitleInElementLabel() throws {
        let title: String = Self.title
        let notice = Notice(title, icon: Icon(.wifiSlash), description: Text(Self.description)) {
            Button("Try Again") {}
        }
        #expect(try readsTitle(of: notice))
    }

    @Test
    func whenNoticeHasAction_shouldReadTitleAndDescriptionAsOneElementThenButton() throws {
        let elements = try AccessibilityTree.elements(of: notice)
        #expect(elements.count == 2)
        let text = try #require(elements.first)
        #expect(text.label == Self.groupedLabel)
        #expect(text.traits == .staticText)
        let action = try #require(elements.last)
        #expect(action.label == "Try Again")
        #expect(action.traits == .button)
    }

    @Test
    func whenNoticeHasTitleAndIconOnly_shouldReadTitleAsOneStaticTextElement() throws {
        let notice = Notice(
            title: { Text(Self.title) },
            icon: { Image(icon: Icon(.wifiSlash)) },
        )
        let elements = try AccessibilityTree.elements(of: notice)
        #expect(elements.count == 1)
        let element = try #require(elements.first)
        #expect(element.label == Self.title)
        #expect(element.traits == .staticText)
    }

    @Test
    func whenStyleDrawsConfigurationIcon_shouldReadOnlyIconOutsideConfiguration() throws {
        let view = notice.noticeStyle(IconBesideOutsideIconStyle())
        let images = try AccessibilityTree.elements(of: view).filter { $0.traits.contains(.image) }
        #expect(images.count == 1)
    }

    @Test
    func whenStyleDoesNotGroup_shouldReadTitleAndDescriptionSeparately() throws {
        let view = notice.noticeStyle(UngroupedNoticeStyle())
        let texts = try AccessibilityTree.elements(of: view).filter { $0.traits == .staticText }
        #expect(texts.map(\.label) == [Self.title, Self.description])
    }

    @Test
    func whenNoticeHasNoActions_shouldReadNoButton() throws {
        let notice = Notice(
            title: { Text(Self.title) },
            icon: { Image(icon: Icon(.wifiSlash)) },
            description: { Text(Self.description) },
        )
        let elements = try AccessibilityTree.elements(of: notice)
        #expect(!elements.contains { $0.traits == .button })
    }

    @Test
    func whenNoticeHasAction_shouldReadOneButton() throws {
        let notice = Notice(
            title: { Text(Self.title) },
            icon: { Image(icon: Icon(.wifiSlash)) },
            description: { Text(Self.description) },
            actions: { Button("Try Again") {} },
        )
        let elements = try AccessibilityTree.elements(of: notice)
        #expect(elements.filter { $0.traits == .button }.count == 1)
    }

    @Test
    func whenNoticeIsInListRow_shouldReadTextThenBorderlessButton() throws {
        let elements = try AccessibilityTree.elements(of: noticeInList)
        #expect(elements.map(\.label) == [Self.groupedLabel, "Try Again"])
        #expect(elements.map(\.traits) == [.staticText, .button])
    }
}
#endif
