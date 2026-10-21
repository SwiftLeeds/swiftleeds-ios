import SwiftUI
import UIDesign

/// A view that cuts the About text to a few lines, with a "More" capsule that opens the full text
/// in a sheet.
///
/// The capsule sits at the trailing end of the last line, and appears only when there is more to
/// read. VoiceOver reads the whole text whether or not it is cut.
struct CutAboutText: View {
    /// How wide the fade is before the capsule.
    private static let fadeWidth: CGFloat = 24

    /// The least a tap target measures on either side.
    private static let tapTarget: CGFloat = 44

    /// The text to show.
    private let text: String

    /// The most lines the text takes until a person asks for the rest.
    private let lines: Int

    /// Whether the sheet with the full text shows.
    @State private var showsFull: Bool

    /// How tall the text is when it shows in full.
    @State private var fullHeight: CGFloat = 0

    /// How tall the text is when it is cut to its first lines.
    @State private var cutHeight: CGFloat = 0

    /// How big the "More" capsule is, or zero until measured.
    @State private var capsuleSize = CGSize.zero

    /// Creates text that is cut until a person opens the full text.
    ///
    /// - Parameters:
    ///   - text: The text to show.
    ///   - lines: The most lines the text takes until opened.
    ///   - opensFull: Whether the sheet with the full text shows when the view appears.
    init(_ text: String, lines: Int, opensFull: Bool = false) {
        self.text = text
        self.lines = lines
        _showsFull = State(initialValue: opensFull)
    }

    /// The cut text, with its capsule when there is more to read.
    var body: some View {
        Text(text)
            .font(.body)
            .foregroundStyle(.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
            .background {
                measure(lines: nil, into: $fullHeight)
                measure(lines: lines, into: $cutHeight)
            }
            .frame(height: isCut ? cutHeight : nil, alignment: .top)
            .clipped()
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .mask { fade }
            .overlay(alignment: .bottomTrailing) {
                if isCut {
                    moreButton
                        .frame(height: lineHeight)
                }
            }
            .sheet(isPresented: $showsFull) {
                fullText
            }
    }
}

// MARK: - Measures

extension CutAboutText {
    /// Whether the text is longer than the lines it shows until opened.
    private var isCut: Bool {
        fullHeight > cutHeight
    }

    /// How tall one line of the text is.
    private var lineHeight: CGFloat {
        cutHeight / CGFloat(lines)
    }

    /// How far the tap target reaches past the capsule on each side.
    private var tapInset: CGFloat {
        max(0, (Self.tapTarget - capsuleSize.height) / 2)
    }

    /// Returns an invisible copy of the text that reports its height.
    ///
    /// - Parameters:
    ///   - lines: The most lines the copy takes, or `nil` for no limit.
    ///   - height: Where the copy's height goes.
    /// - Returns: A view that is hidden and reports its height.
    private func measure(lines: Int?, into height: Binding<CGFloat>) -> some View {
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

// MARK: - Capsule

extension CutAboutText {
    /// The mask that fades the last line out before the capsule.
    @ViewBuilder
    private var fade: some View {
        if isCut {
            VStack(spacing: 0) {
                Rectangle()

                HStack(spacing: 0) {
                    Rectangle()

                    LinearGradient(
                        colors: [.black, .clear],
                        startPoint: .leading,
                        endPoint: .trailing,
                    )
                    .frame(width: Self.fadeWidth)

                    Color.clear
                        .frame(width: capsuleSize.width)
                }
                .frame(height: lineHeight)
            }
        } else {
            Rectangle()
        }
    }

    /// The capsule that opens the full text.
    ///
    /// Its tap target grows past the capsule to at least 44 points.
    private var moreButton: some View {
        Button {
            showsFull = true
        } label: {
            Text("More")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.textPrimary)
                .padding(.horizontal, .medium)
                .padding(.vertical, .xxSmall)
                .background(.surface, in: .capsule)
                .onGeometryChange(for: CGSize.self) { proxy in
                    proxy.size
                } action: { size in
                    capsuleSize = size
                }
                .contentShape(Rectangle().inset(by: -tapInset))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("More")
        .accessibilityHint("Shows the full description")
    }
}

// MARK: - Sheet

extension CutAboutText {
    /// The sheet that shows the whole text.
    private var fullText: some View {
        NavigationStack {
            ScrollView {
                Text(text)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.large)
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showsFull = false
                    }
                    .tint(.primary)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
