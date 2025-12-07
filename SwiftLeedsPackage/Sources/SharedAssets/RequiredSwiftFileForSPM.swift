// File needed to avoid Swift Package compilation error

import SwiftUI

struct Test: View {
    var body: some View {
        ZStack {
            Color.accent
            Image.appIconPreview2024
        }
        .edgesIgnoringSafeArea(.vertical)
    }
}

#Preview {
    Test()
}
