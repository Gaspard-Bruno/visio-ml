import Foundation
import CoreImage


extension AppData {
  func generateSynthetics(selectionOnly: Bool) {

    let initialSet = selectionOnly
      ? annotatedImages.filter { $0.isMarked }
      : annotatedImages

    let newImages = initialSet.map {
      $0.generateGaussianBlur(completion: self.syntheticCompletedWithUrl)
    }
    annotatedImages.append(contentsOf: newImages)

    annotatedImages.append(contentsOf:initialSet.map {
      $0.generateColorMonochrome(completion: self.syntheticCompletedWithUrl)
    })
  }
  
  func syntheticCompletedWithUrl(_ url: URL) {
    guard let i = annotatedImages.firstIndex(where: { $0.url == url }) else {
      return
    }
    annotatedImages[i].isEnabled.toggle()
  }
}

extension AnnotatedImage {

  func generateGaussianBlur(completion: @escaping (URL) -> ()) -> AnnotatedImage {
    let newUrl = url.deletingPathExtension().appendingPathExtension(UUID().uuidString).appendingPathExtension("png")
    let synthetic = AnnotatedImage(url: newUrl, annotations: annotations, isEnabled: false)
    DispatchQueue.global(qos: .userInteractive).async {
      SyntheticsProcessor.shared.blur(image: self.ciImage, url: newUrl) {
        DispatchQueue.main.async {
          completion(newUrl)
        }
      }
    }
    return synthetic
  }

  func generateColorMonochrome(completion: @escaping (URL) -> ()) -> AnnotatedImage {
    let newUrl = url.deletingPathExtension().appendingPathExtension(UUID().uuidString).appendingPathExtension("png")
    let synthetic = AnnotatedImage(url: newUrl, annotations: annotations, isEnabled: false)
    DispatchQueue.global(qos: .userInteractive).async {
      SyntheticsProcessor.shared.monochrome(image: self.ciImage, url: newUrl) {
        DispatchQueue.main.async {
          completion(newUrl)
        }
      }
    }
    return synthetic
  }

}

class SyntheticsProcessor {

  static let shared = SyntheticsProcessor()

  let context = CIContext()
  let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!

  func blur(image: CIImage, url: URL ,completion: @escaping () -> ()) {
    let newCiImage: CIImage = image.applyingGaussianBlur(sigma: 10.0)
    save(newCiImage, toUrl: url)
    completion()
  }
  
  func monochrome(image: CIImage, url: URL ,completion: @escaping () -> ()) {
    let newCiImage: CIImage = image.applyingFilter("CIColorMonochrome", parameters: [
      kCIInputColorKey: CIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1)),
      kCIInputIntensityKey: NSNumber(value: 1.0)
    ])
    save(newCiImage, toUrl: url)
    completion()
  }
  
  func save(_ image: CIImage, toUrl url: URL) {
    do {
      try self.context.writePNGRepresentation(of: image, to: url, format: .RGBA8, colorSpace: self.colorSpace)
    } catch {
      print("Error writing PNG.\n\n\(error.localizedDescription)")
    }
  }
}
