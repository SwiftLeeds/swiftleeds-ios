#if os(iOS)
import SFSafeSymbols
import SwiftUI
import Testing
import UIDesign

@MainActor
@Suite
struct NoticeAccessibilityTests {
    /// The title every test gives its notice.
    private static let title = "You're offline"

    /// The description every test gives its notice.
    private static let description = Text("The schedule shows what was saved.")

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
        let notice = Notice("You're offline", icon: Icon(.wifiSlash), description: Self.description) {
            Button("Try Again") {}
        }
        #expect(try readsTitle(of: notice))
    }

    @Test
    func whenTitleIsLocalizedStringResource_shouldReadTitleInElementLabel() throws {
        let title = LocalizedStringResource("You're offline")
        let notice = Notice(title, icon: Icon(.wifiSlash), description: Self.description) {
            Button("Try Again") {}
        }
        #expect(try readsTitle(of: notice))
    }

    @Test
    func whenTitleIsString_shouldReadTitleInElementLabel() throws {
        let title: String = Self.title
        let notice = Notice(title, icon: Icon(.wifiSlash), description: Self.description) {
            Button("Try Again") {}
        }
        #expect(try readsTitle(of: notice))
    }
}
#endif
