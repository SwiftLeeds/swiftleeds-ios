import ColorTheme
import SwiftUI

public struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var viewModel = SettingsViewModel()

    public init() {}

    public var body: some View {
        NavigationView {
            List {
                Section("App Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                        ForEach(AppIconOption.allCases, id: \.self) { iconOption in
                            AppIconButton(
                                iconOption: iconOption,
                                isSelected: viewModel.currentIcon == iconOption,
                                action: {
                                    viewModel.changeAppIcon(to: iconOption)
                                }
                            )
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Appearance") {
                    Picker("Theme", selection: $themeManager.currentTheme) {
                        ForEach(ThemeOption.allCases, id: \.self) { theme in
                            Text(theme.displayName).tag(theme)
                        }
                    }
                    .onChange(of: themeManager.currentTheme) { newTheme in
                        themeManager.setTheme(newTheme)
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(viewModel.appVersion)
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Contact Us") {
                        viewModel.openContactUs()
                    }
                    
                    Button("Code of Conduct") {
                        viewModel.openCodeOfConduct()
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Icon Change Failed", isPresented: $viewModel.showingIconError) {
                Button("OK") { }
            } message: {
                Text("Unable to change app icon. Please try again.")
            }
        }
    }
}

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
                        .aspectRatio(contentMode: .fit)
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

enum AppIconOption: String, CaseIterable {
    case generic = "AppIcon"
    case space = "AppIcon-Space"
    case olympics = "AppIcon-Olympics"
    
    var displayName: String {
        switch self {
        case .generic: return "General"
        case .space: return "Space"
        case .olympics: return "Sports"
        }
    }
    
    var iconImage: UIImage? {
        switch self {
        case .generic:
            return UIImage(named: "AppIconPreview-2024")
        case .space:
            return UIImage(named: "AppIconPreview-Space")
        case .olympics:
            return UIImage(named: "AppIconPreview-Olympics")
        }
    }
    
    var iconName: String? {
        return self == .generic ? nil : rawValue
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(ThemeManager.shared)
    }
}
