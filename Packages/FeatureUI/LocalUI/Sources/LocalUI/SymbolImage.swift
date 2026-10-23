#if canImport(UIKit)
import SwiftUI
import UIKit

/// Resolves a symbol by name.
///
/// Falls back to an asset catalog image of the same name. That lookup checks
/// only the main bundle, so a symbol shipped in a package's own resource
/// bundle, such as UIAssets, is not found this way.
///
/// - Parameter name: The SF Symbol, or asset catalog image, name.
func symbolImage(named name: String) -> Image {
    Image(uiImage: UIImage(systemName: name) ?? UIImage(imageLiteralResourceName: name))
}
#endif
