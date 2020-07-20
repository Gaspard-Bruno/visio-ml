import Foundation
import CoreImage

extension SyntheticsTask {

  func applyScale() {
    let randomScaleX = CGFloat.random(in: 0.75 ..< 1.25)
    let randomScaleY = CGFloat.random(in: 0.75 ..< 1.25)
    let scaleTransform = CGAffineTransform(scaleX: randomScaleX, y: randomScaleY)

    resultAnnotations = resultAnnotations.map { (annotation: Annotation) in
      let newCoords = annotation.coordinates.applying(scaleTransform).pixelRound
      return Annotation(label: annotation.label, coordinates: newCoords)
    }
    resultImage = resultImage.transformed(by: scaleTransform)
  }
}
