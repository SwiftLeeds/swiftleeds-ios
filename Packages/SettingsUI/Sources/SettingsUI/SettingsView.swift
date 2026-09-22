#if canImport(UIKit)
import ColorTheme
import Sharing
import SwiftUI

public struct SettingsView<Header: View>: View {
    @Shared(.selectedTheme) private var theme
    @StateObject private var viewModel = SettingsViewModel()
    private let header: Header

    public init(@ViewBuilder header: () -> Header = { EmptyView() }) {
        self.header = header()
    }

    public var body: some View {
        NavigationStack {
            List {
                header

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
                    Picker("Theme", selection: Binding($theme)) {
                        ForEach(ThemeOption.allCases, id: \.self) { theme in
                            Text(theme.displayName).tag(theme)
                        }
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
#endif
