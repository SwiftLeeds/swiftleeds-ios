// swiftlint:disable all
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif

// MARK: - Backwards Deployment Support -

/// A color resource.
public struct SLColorResource: Swift.Hashable, Swift.Sendable {
    /// An asset catalog color resource name.
    let name: Swift.String

    /// An asset catalog color resource bundle.
    let bundle: Foundation.Bundle

    /// Initialize a `SLColorResource` with `name` and `bundle`.
    init(name: Swift.String, bundle: Foundation.Bundle) {
        self.name = name
        self.bundle = bundle
    }
}

#if canImport(SwiftUI)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Color {
    private init?(thinnableResource: SLColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {
    private init?(thinnableResource: SLColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension SwiftUI.Color {
    /// Initialize a `Color` with a color resource.
    init(_ resource: SLColorResource) {
        self.init(resource.name, bundle: resource.bundle)
    }

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
public extension UIKit.UIColor {
    /// Initialize a `UIColor` with a color resource.
    convenience init(resource: SLColorResource) {
#if !os(watchOS)
        self.init(named: resource.name, in: resource.bundle, compatibleWith: nil)!
#else
        self.init()
#endif
    }

}
#endif
// swiftlint:enable all
