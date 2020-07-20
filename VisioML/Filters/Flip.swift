import Foundation
import CoreImage

extension SyntheticsTask {

  func applyFlip() {
    let size = resultImage.extent.size
    resultAnnotations = resultAnnotations.map { (annotation: Annotation) in
      let newCoords = CGRect(
        origin: CGPoint(x: size.width - annotation.coordinates.origin.x, y: annotation.coordinates.origin.y),
        size: annotation.coordinates.size
      )
      // Another way
      // let newCoords = annotation.coordinates.applying(CGAffineTransform(scaleX: -1, y: 1).translatedBy(x: -size.width - annotation.coordinates.size.width, y: 0))
      return Annotation(label: annotation.label, coordinates: newCoords)
    }
    resultImage = resultImage.transformed(by: .init(scaleX: -1, y: 1))
    resultImage = resultImage.transformed(by: .init(translationX: -resultImage.extent.origin.x, y: -resultImage.extent.origin.y))
  }
}
