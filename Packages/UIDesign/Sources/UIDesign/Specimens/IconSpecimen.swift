#if DEBUG
import SwiftUI

/// Draws every icon in the vocabulary beside its name.
///
/// Its snapshot pins the symbol each role maps to.
package struct IconSpecimen: View {
    package init() {}

    package var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: Spacing.xLarge) { groups }
            VStack(alignment: .leading, spacing: Spacing.xLarge) { groups }
        }
        .padding(Spacing.large)
    }

    @ViewBuilder
    private var groups: some View {
        navigationGroup
        actionGroup
        stateGroup
        contentGroup
    }
}

// MARK: - Groups

private extension IconSpecimen {
    var navigationGroup: some View {
        SpecimenGroup("Navigation") {
            GridRow { Text("back"); Glyph(.back) }
            GridRow { Text("forward"); Glyph(.forward) }
            GridRow { Text("close"); Glyph(.close) }
            GridRow { Text("more"); Glyph(.more) }
        }
    }

    var actionGroup: some View {
        SpecimenGroup("Action") {
            GridRow { Text("share"); Glyph(.share) }
            GridRow { Text("favorite"); Glyph(.favorite) }
            GridRow { Text("favoriteFilled"); Glyph(.favoriteFilled) }
            GridRow { Text("add"); Glyph(.add) }
            GridRow { Text("delete"); Glyph(.delete) }
            GridRow { Text("edit"); Glyph(.edit) }
            GridRow { Text("search"); Glyph(.search) }
            GridRow { Text("filter"); Glyph(.filter) }
            GridRow { Text("sort"); Glyph(.sort) }
            GridRow { Text("refresh"); Glyph(.refresh) }
            GridRow { Text("copy"); Glyph(.copy) }
            GridRow { Text("openExternal"); Glyph(.openExternal) }
        }
    }

    var stateGroup: some View {
        SpecimenGroup("State") {
            GridRow { Text("success"); Glyph(.success) }
            GridRow { Text("warning"); Glyph(.warning) }
            GridRow { Text("error"); Glyph(.error) }
            GridRow { Text("info"); Glyph(.info) }
            GridRow { Text("locked"); Glyph(.locked) }
            GridRow { Text("live"); Glyph(.live) }
        }
    }

    var contentGroup: some View {
        SpecimenGroup("Content") {
            GridRow { Text("calendar"); Glyph(.calendar) }
            GridRow { Text("clock"); Glyph(.clock) }
            GridRow { Text("location"); Glyph(.location) }
            GridRow { Text("person"); Glyph(.person) }
            GridRow { Text("link"); Glyph(.link) }
            GridRow { Text("document"); Glyph(.document) }
            GridRow { Text("video"); Glyph(.video) }
            GridRow { Text("ticket"); Glyph(.ticket) }
        }
    }
}

// MARK: - Parts

// Fixed frame, so a wide symbol doesn't shift the column.
private struct Glyph: View {
    private let icon: Icon

    init(_ icon: Icon) {
        self.icon = icon
    }

    var body: some View {
        Image(icon: icon)
            .imageScale(.large)
            .frame(width: IconSize.xxLarge, alignment: .leading)
    }
}

#Preview {
    ScrollView([.horizontal, .vertical]) {
        IconSpecimen()
    }
}
#endif
