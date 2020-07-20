import Foundation
import CoreImage

class SyntheticsTask {

  let source: AnnotatedImage
  let settings: WorkspaceSettings
  let operations: [Operation]
  let resultUrl: URL

  var resultAnnotations: [Annotation]!
  var resultImage: CIImage!
  
  init(annotatedImage: AnnotatedImage, settings: WorkspaceSettings, operations: [Operation]) {
    self.source = annotatedImage
    self.settings = settings
    self.operations = operations
    self.resultUrl = annotatedImage.url
      .deletingPathExtension()
      .appendingPathExtension(UUID.tiny())
      .appendingPathExtension(annotatedImage.url.pathExtension)
  }

  func process() {
    resultAnnotations = source.annotations
    resultImage = CIImage(contentsOf: source.url)!
    for op in operations {
      switch op {
      case .flip:
        applyFlip()
      case .scale:
        applyScale()
      case .rotate:
        applyRotation()
      case .background:
        applyBackground()
      case .blur:
        applyBlur()
      case .monochrome:
        applyMonochrome()
      case .emboss:
        applyEmboss()
      case .noise:
        applyNoise()
      case .crop:
        applyCrop()
      case .cutout:
        applyCutout()
      }
    }
    SyntheticsProcessor.shared.save(resultImage, toUrl: resultUrl)
  }
}

extension Array where Element == SyntheticsTask {

  func processAll(completion: @escaping (SyntheticsTask) -> ()) {
    DispatchQueue.global(qos: .userInteractive).async {
      self.forEach { task in
        task.process()
        completion(task)
      }
    }
  }
}
