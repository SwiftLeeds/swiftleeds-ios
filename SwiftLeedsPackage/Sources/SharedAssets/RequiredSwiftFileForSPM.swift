// File needed to avoid Swift Package compilation error

import SwiftUI

struct Test: View {
    let color: SLColorResource = .accent
    let image: SLImageResource = .appIconPreview2024

    var body: some View {
        ZStack {
            Color(color)
            Image(SLImageResource.appIconPreview2024)
        }
        .edgesIgnoringSafeArea(.vertical)
    }
}

#Preview {
    Test()
}
