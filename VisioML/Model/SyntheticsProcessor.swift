import CoreImage

class SyntheticsProcessor {

  static let shared = SyntheticsProcessor()

  let context = CIContext()
  let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!

  func save(_ image: CIImage, toUrl url: URL) {
    do {
      try self.context.writePNGRepresentation(of: image, to: url, format: .RGBA8, colorSpace: self.colorSpace)
    } catch {
      print("Error writing PNG.\n\n\(error.localizedDescription)")
    }
  }
}
