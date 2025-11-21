import SwiftUI

struct ShimmerView: View {
    @State private var shimmerOffset: CGFloat = -1
    
    private let colors: [Color]
    private let duration: Double
    
    init(colors: [Color] = [
        Color.gray.opacity(0.2),
        Color.gray.opacity(0.3),
        Color.gray.opacity(0.2)
    ], duration: Double = 1.5) {
        self.colors = colors
        self.duration = duration
    }
    
    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: colors,
                        startPoint: UnitPoint(x: shimmerOffset - 1, y: 0),
                        endPoint: UnitPoint(x: shimmerOffset, y: 0)
                    )
                )
                .onAppear {
                    withAnimation(
                        Animation.linear(duration: duration)
                            .repeatForever(autoreverses: false)
                    ) {
                        shimmerOffset = 2
                    }
                }
        }
        .clipped()
    }
}

struct ShimmerView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            Rectangle()
                .frame(height: 100)
                .overlay(ShimmerView())
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Rectangle()
                .frame(height: 50)
                .overlay(ShimmerView(colors: [
                    Color.blue.opacity(0.2),
                    Color.blue.opacity(0.4),
                    Color.blue.opacity(0.2)
                ]))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding()
    }
}
