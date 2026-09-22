#if canImport(UIKit)
import ColorTheme
import Sharing
import SwiftUI

public struct SettingsView<Header: View>: View {
    @Shared(.selectedTheme) private var theme
    @State private var viewModel: SettingsViewModel
    private let header: Header

    /// Creates the Settings screen.
    ///
    /// - Parameters:
    ///   - contactEmail: The address the Contact Us button writes to.
    ///   - appVersion: The version the screen shows.
    ///   - header: Rows shown above the app icon picker.
    public init(
        contactEmail: ContactEmail,
        appVersion: AppVersion,
        @ViewBuilder header: () -> Header = { EmptyView() }
    ) {
        _viewModel = State(initialValue: SettingsViewModel(contactEmail: contactEmail, appVersion: appVersion))
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
                                    Task { await viewModel.changeAppIcon(to: iconOption) }
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
                        Text(String(viewModel.appVersion))
                            .foregroundColor(.secondary)
                    }

                    Button("Contact Us") {
                        Task { await viewModel.openContactUs() }
                    }

                    Button("Code of Conduct") {
                        Task { await viewModel.openCodeOfConduct() }
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
        if let contactEmail = try? ContactEmail("hello@conference.example"),
           let appVersion = try? AppVersion("2.1.0") {
            SettingsView(contactEmail: contactEmail, appVersion: appVersion)
        }
    }
}
#endif
