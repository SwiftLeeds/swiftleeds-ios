import SwiftUI

struct Tabs: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        GeometryReader { ruler in
            if ruler.size.width < ruler.size.height || horizontalSizeClass == .compact {
                TabsMainView()
            } else {
                SidebarMainView()
            }
        }
    }
}

struct Tabs_Previews: PreviewProvider {
    static var previews: some View {
        Tabs()
    }
}
