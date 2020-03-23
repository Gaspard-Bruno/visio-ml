import Combine
import Foundation
import AppKit
import CoreImage

class ImageModel: Identifiable, Equatable, Hashable, ObservableObject {

  @Published var url: URL
  @Published var currentScaledSize = CGSize(width: 0, height: 0)
  
  var ciImage: CIImage {
    CIImage(contentsOf: url)!
  }
  var nsImage: NSImage {
    NSImage(byReferencing: url)
  }
  
  var size: CGSize {
    ciImage.extent.size
  }
  
  var aspectRatio: CGFloat {
    size.width / size.height
  }

  var currentScale: CGFloat {
    currentScaledSize.width / size.width
  }

  static func == (lhs: ImageModel, rhs: ImageModel) -> Bool {
    lhs.url == rhs.url && lhs.currentScaledSize == rhs.currentScaledSize
  }

  var filename: String {
    url.lastPathComponent
  }
  
  var id: String {
    "\(url)"
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(url)
    hasher.combine(currentScaledSize.width)
    hasher.combine(currentScaledSize.height)
  }
  
  init(url: URL) {
    self.url = url
  }

  func flipVertically() -> ImageModel? {
    let newUrl = url.deletingPathExtension().appendingPathExtension("v_flipped").appendingPathExtension("png")
    let flipped = ciImage.transformed(by: .init(scaleX: 1, y: -1))
    let context = CIContext()
    guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
      return nil
    }
    do {
      try context.writePNGRepresentation(of: flipped, to: newUrl, format: .RGBA8, colorSpace: colorSpace)
    } catch {
      return nil
    }
    return ImageModel(url: newUrl)
  }

  func flipHorizontally() -> ImageModel? {
    let newUrl = url.deletingPathExtension().appendingPathExtension("h_flipped").appendingPathExtension("png")
    let flipped = ciImage.transformed(by: .init(scaleX: -1, y: 1))
    let context = CIContext()
    guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
      return nil
    }
    do {
      try context.writePNGRepresentation(of: flipped, to: newUrl, format: .RGBA8, colorSpace: colorSpace)
    } catch {
      return nil
    }
    return ImageModel(url: newUrl)
  }

  static var specimen: ImageModel {
    //ImageModel(url: Bundle.main.url(forResource: "cat-and-dog", withExtension: "png", subdirectory: "samples")!)
    ImageModel(url: Bundle.main.url(forResource: "cat-and-dog", withExtension: "png")!)
  }
}
