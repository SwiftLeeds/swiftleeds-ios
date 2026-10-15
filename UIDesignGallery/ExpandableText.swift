import SwiftUI
import UIDesign

/// A view that shows text cut to its first lines until a person asks for
/// the rest.
///
/// Two hidden copies measure the text in full and cut, so "See more" appears
/// only when there is more to read. VoiceOver reads the whole text whether or
/// not it is cut. The text and the button are two rows, so this view belongs
/// inside a `Section`.
struct ExpandableText: View {
    /// The text to show.
    let text: String

    /// The most lines the text takes until a person asks for the rest.
    let lines: Int

    /// Whether the text shows in full.
    @State private var isExpanded: Bool

    /// How tall the text is when it shows in full.
    @State private var fullHeight: CGFloat = 0

    /// How tall the text is when it is cut to its first lines.
    @State private var cutHeight: CGFloat = 0

    /// Creates text that is cut until a person expands it.
    ///
    /// - Parameters:
    ///   - text: The text to show.
    ///   - lines: The most lines the text takes until expanded.
    ///   - opensExpanded: Whether the text shows in full when the view
    ///     appears.
    init(_ text: String, lines: Int, opensExpanded: Bool = false) {
        self.text = text
        self.lines = lines
        _isExpanded = State(initialValue: opensExpanded)
    }

    @ViewBuilder
    var body: some View {
        cutText

        if isCut || isExpanded {
            // A plain button takes taps on its label only, so the label fills
            // the row and the whole row answers.
            Button {
                isExpanded.toggle()
            } label: {
                Text(isExpanded ? "See less" : "See more")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .font(.body)
            .foregroundStyle(.brandPrimary)
        }
    }

    /// Whether the text is longer than the lines it shows until expanded.
    private var isCut: Bool {
        fullHeight > cutHeight
    }

    /// The text, cut to its first lines until it is expanded.
    private var cutText: some View {
        Text(text)
            .font(.body)
            .foregroundStyle(.textPrimary)
            .lineLimit(isExpanded ? nil : lines)
            .fixedSize(horizontal: false, vertical: true)
            .background {
                measure(lines: nil, into: $fullHeight)
                measure(lines: lines, into: $cutHeight)
            }
    }

    /// Returns an invisible copy of the text that reports its height.
    ///
    /// - Parameters:
    ///   - lines: The most lines the copy takes, or `nil` for no limit.
    ///   - height: Where the copy's height goes.
    private func measure(
        lines: Int?,
        into height: Binding<CGFloat>,
    ) -> some View {
        Text(text)
            .font(.body)
            .lineLimit(lines)
            .fixedSize(horizontal: false, vertical: true)
            .hidden()
            .accessibilityHidden(true)
            .onGeometryChange(for: CGFloat.self) {
                $0.size.height
            } action: { new in
                height.wrappedValue = new
            }
    }
}
