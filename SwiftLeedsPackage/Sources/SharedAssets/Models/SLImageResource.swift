// swiftlint:disable all
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif

// MARK: - Backwards Deployment Support -

/// An image resource.
public struct SLImageResource: Swift.Hashable, Swift.Sendable {

    /// An asset catalog image resource name.
    fileprivate let name: Swift.String

    /// An asset catalog image resource bundle.
    fileprivate let bundle: Foundation.Bundle

    /// Initialize an `SLImageResource` with `name` and `bundle`.
    init(name: Swift.String, bundle: Foundation.Bundle) {
        self.name = name
        self.bundle = bundle
    }
}

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
public extension UIKit.UIImage {
    /// Initialize a `UIImage` with an image resource.
    convenience init(resource: SLImageResource) {
#if !os(watchOS)
        self.init(named: resource.name, in: resource.bundle, compatibleWith: nil)!
#else
        self.init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension SwiftUI.Image {
    /// Initialize an `Image` with an image resource.
    init(_ resource: SLImageResource) {
        self.init(resource.name, bundle: resource.bundle)
    }

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: SLImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(AppKit)
@available(macOS 10.7, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: SLImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

@available(iOS 11.0, macOS 10.7, tvOS 11.0, *)
@available(watchOS, unavailable)
extension SLImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(SwiftUI)
public extension Button where Label == SwiftUI.Label<AnyView, Image?> {
    init(
        _ titleKey: any StringProtocol,
        imageResource: SLImageResource? = nil,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) {
        self.init(
            role: role,
            action: action,
            label: {
                Label(
                    title: {
                        AnyView(
                            Text(titleKey)
                                .accessibilityIdentifier(
                                    "button\(titleKey.capitalized.replacingOccurrences(of: " ", with: ""))"
                                )
                        )
                    },
                    icon: { if let imageResource { Image(imageResource) } }
                )
            }
        )
    }
}
#endif
// swiftlint:enable all
