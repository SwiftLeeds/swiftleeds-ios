#if canImport(UIKit)
import SwiftUI

struct AppIconButton: View {
    let iconOption: AppIconOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                if let uiImage = iconOption.iconImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 3)
                        )
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "questionmark.app")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.gray)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 3)
                        )
                }

                Text(iconOption.displayName)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(isSelected ? .accentColor : .primary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
#endif
