import Foundation
import CoreImage

extension SyntheticsTask {

  func applyRotation() {
    let randomAngle = CGFloat.random(in: -.pi ..< .pi)
    let originalExtent = resultImage.extent

    resultImage = resultImage.rotateInPlace(angle: randomAngle)

    let rotateTransform = CGAffineTransform(rotationAngle: randomAngle, center: originalExtent.center)
    resultAnnotations = resultAnnotations.map { (annotation: Annotation) in
      let newCoords = annotation.coordinates
        .centerToBottomLeftCoords
        .flipCoordSystem(container: originalExtent)
        .applying(rotateTransform).pixelRound
        .reframe(source: originalExtent, target: resultImage.extent)
        .flipCoordSystem(container: resultImage.extent)
        .bottomLeftToCenterCoords
      return Annotation(label: annotation.label, coordinates: newCoords)
    }
  }

}
