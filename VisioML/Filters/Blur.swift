import Foundation
import CoreImage

extension SyntheticsTask {

  func applyBlur() {
    resultAnnotations = resultAnnotations.map {
      Annotation(label: $0.label, coordinates: $0.coordinates)
    }
    let originalExtent = resultImage.extent
    resultImage = resultImage.applyingGaussianBlur(sigma: 10.0)
    resultImage = resultImage.cropped(to: originalExtent)
  }
}
