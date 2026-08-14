import SwiftUI

/// The code a ``BarcodeStyle`` arranges.
package struct BarcodeStyleConfiguration {
    package struct Code: View {
        let base: AnyView

        package var body: some View { base }
    }

    package let code: Code
}

/// The look of a ``Barcode``: its padding, backing and shape.
///
/// A style must not change what the code encodes, only how it sits on screen.
package protocol BarcodeStyle {
    associatedtype Body: View

    @ViewBuilder func makeBody(configuration: BarcodeStyleConfiguration) -> Body
}

/// A code on a white plate with rounded corners.
package struct InsetBarcodeStyle: BarcodeStyle {
    private let cornerRadius: CGFloat

    package init(cornerRadius: CGFloat = 16) {
        self.cornerRadius = cornerRadius
    }

    package func makeBody(configuration: BarcodeStyleConfiguration) -> some View {
        configuration.code
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

/// A code with nothing around it.
///
/// Still scannable: every generated code carries its own light margin.
package struct PlainBarcodeStyle: BarcodeStyle {
    package init() {}

    package func makeBody(configuration: BarcodeStyleConfiguration) -> some View {
        configuration.code
    }
}

package extension BarcodeStyle where Self == InsetBarcodeStyle {
    static var inset: InsetBarcodeStyle { InsetBarcodeStyle() }

    static func inset(cornerRadius: CGFloat) -> InsetBarcodeStyle {
        InsetBarcodeStyle(cornerRadius: cornerRadius)
    }
}

package extension BarcodeStyle where Self == PlainBarcodeStyle {
    static var plain: PlainBarcodeStyle { PlainBarcodeStyle() }
}

struct AnyBarcodeStyle {
    let makeBody: (BarcodeStyleConfiguration) -> AnyView

    init<S: BarcodeStyle>(_ style: S) {
        makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }
}

private struct BarcodeStyleKey: EnvironmentKey {
    static var defaultValue: AnyBarcodeStyle { AnyBarcodeStyle(InsetBarcodeStyle()) }
}

extension EnvironmentValues {
    var barcodeStyle: AnyBarcodeStyle {
        get { self[BarcodeStyleKey.self] }
        set { self[BarcodeStyleKey.self] = newValue }
    }
}

package extension View {
    /// Sets the look of scannable codes in this view.
    func barcodeStyle<S: BarcodeStyle>(_ style: S) -> some View {
        environment(\.barcodeStyle, AnyBarcodeStyle(style))
    }
}
