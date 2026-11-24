#if os(macOS)
import CoreGraphics
import CoreImage
import Vision

/// Reads the text a barcode image carries, with Vision, on macOS only.
///
/// Vision decodes nothing in the iOS simulator, so snapshot tests cannot use it.
enum BarcodeReader {
    /// The pixels the stored picture spends on each module.
    private static let pixelsPerModule = 10

    /// The modules of white border the reader adds on each side, so a scan does not depend on the code.
    private static let borderModules = 10

    /// The context that draws the white page, in software so the result is the same everywhere.
    private static let context = CIContext(options: [.useSoftwareRenderer: true])

    /// Returns the text a barcode in an image carries.
    ///
    /// The reader draws the image over opaque white with its own border first, because a clear
    /// pixel can read as black.
    ///
    /// - Parameters:
    ///   - image: The barcode image, at ten pixels for each module.
    ///   - symbology: The kind of barcode to look for.
    /// - Returns: The text, or `nil` when Vision finds no barcode of that kind.
    static func payload(of image: CGImage, as symbology: VNBarcodeSymbology) -> String? {
        guard let page = onWhitePage(image) else { return nil }
        let request = VNDetectBarcodesRequest()
        request.symbologies = [symbology]
        do {
            try VNImageRequestHandler(cgImage: page, options: [:]).perform([request])
        } catch {
            return nil
        }
        return request.results?.compactMap(\.payloadStringValue).first
    }

    /// Returns an image drawn over opaque white, with a border on every side.
    ///
    /// - Parameter image: The image to draw.
    /// - Returns: The image on white, or `nil` when CoreImage draws none.
    private static func onWhitePage(_ image: CGImage) -> CGImage? {
        let picture = CIImage(cgImage: image)
        let border = CGFloat(borderModules * pixelsPerModule)
        let page = CIImage(color: .white).cropped(to: picture.extent.insetBy(dx: -border, dy: -border))
        let composite = picture.composited(over: page)
        return context.createCGImage(composite, from: composite.extent)
    }
}
#endif
