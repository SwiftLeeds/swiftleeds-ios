// File needed to avoid Swift Package compilation error

import SwiftUI

struct Test: View {
    let color: ColorResource = .accent

    var body: some View {
        Color(color)
        Text("Hi there!")
    }
}

#Preview {
    Test()
}
