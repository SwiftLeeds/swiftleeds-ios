// File needed to avoid Swift Package compilation error

import SwiftUI

struct Test: View {
    let color: SLColorResource = .accent

    var body: some View {
        Color(color)
    }
}

#Preview {
    Test()
}
