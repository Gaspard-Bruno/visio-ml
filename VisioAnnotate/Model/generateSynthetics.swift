import Foundation
import CoreImage

struct Synthetic {

  let sourceImage: AnnotatedImage
  let operations: [Operation]
  let annotated: AnnotatedImage

  enum Operation {
    case blur
    case monochrome
  }
  
  init(sourceImage: AnnotatedImage, operations: [Operation]) {
    self.sourceImage = sourceImage
    self.operations = operations
    var last = sourceImage
    for op in operations {
      switch op {
        case .blur:
          last = last.applyBlur()
        case .monochrome:
          last = last.applyMonochrome()
      }
    }
    self.annotated = last
  }

  func process() {
    var last = CIImage(contentsOf: sourceImage.url)!
    for op in operations {
      switch op {
        case .blur:
          last = SyntheticsProcessor.shared.blur(image: last)
        case .monochrome:
          last = SyntheticsProcessor.shared.monochrome(image: last)
      }
    }
    SyntheticsProcessor.shared.save(last, toUrl: annotated.url)
  }
}

extension Array where Element == Synthetic {

  var annotated: [AnnotatedImage] {
    map {
      $0.annotated
    }
  }
  
  func processAll(completion: @escaping (URL) -> ()) {
    DispatchQueue.global(qos: .userInteractive).async {
      self.forEach { synthetic in
        let annotated = synthetic.annotated
        synthetic.process()
        completion(annotated.url)
      }
    }
  }
}

extension AppData {
  func generateSynthetics(selectionOnly: Bool) {
  
    folderWatcher?.suspend()

    let initialSet = selectionOnly
      ? annotatedImages.filter { $0.isMarked }
      : annotatedImages

    let synthetics = initialSet.map {
      Synthetic(sourceImage: $0, operations: [.blur, .monochrome])
    }
    annotatedImages.append(contentsOf: synthetics.annotated)
    
    synthetics.processAll { url in
      DispatchQueue.main.async {
        self.syntheticCompletedWithUrl(url)
      }
    }
  }
  
  func syntheticCompletedWithUrl(_ url: URL) {
    guard let i = annotatedImages.firstIndex(where: { $0.url == url }) else {
      return
    }

    annotatedImages[i].isEnabled.toggle()
    if pendingImages == 0 {
      folderWatcher?.resume()
    }
  }
}

extension UUID {
  static func tiny() -> String {
    Self.init().uuidString.prefix(7).lowercased()
  }
}

extension AnnotatedImage {

  func applyBlur() -> AnnotatedImage {
    let newUrl = url.deletingPathExtension().appendingPathExtension(UUID.tiny()).appendingPathExtension("png")
    let synthetic = AnnotatedImage(url: newUrl, annotations: annotations, isEnabled: false)
    return synthetic
  }

  func applyMonochrome() -> AnnotatedImage {
    let newUrl = url.deletingPathExtension().appendingPathExtension(UUID.tiny()).appendingPathExtension("png")
    let synthetic = AnnotatedImage(url: newUrl, annotations: annotations, isEnabled: false)
    return synthetic
  }
}

class SyntheticsProcessor {

  static let shared = SyntheticsProcessor()

  let context = CIContext()
  let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!

  func blur(image: CIImage) -> CIImage {
    image.applyingGaussianBlur(sigma: 10.0)
  }
  
  func monochrome(image: CIImage) -> CIImage {
    image.applyingFilter("CIColorMonochrome", parameters: [
      kCIInputColorKey: CIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1)),
      kCIInputIntensityKey: NSNumber(value: 1.0)
    ])
  }
  
  func save(_ image: CIImage, toUrl url: URL) {
    do {
      try self.context.writePNGRepresentation(of: image, to: url, format: .RGBA8, colorSpace: self.colorSpace)
    } catch {
      print("Error writing PNG.\n\n\(error.localizedDescription)")
    }
  }
}
