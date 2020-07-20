import Foundation
import CoreImage

extension SyntheticsTask {

  func applyCrop() {
    let randomX = CGFloat.random(in: 0 ... resultImage.extent.width / 5)
    let randomY = CGFloat.random(in: 0 ... resultImage.extent.height / 5)
    let randomWidth = CGFloat.random(in: (resultImage.extent.width - randomX) * 2 / 3 ... resultImage.extent.width - randomX)
    let randomHeight = CGFloat.random(in: (resultImage.extent.height - randomY) * 2 / 3 ... resultImage.extent.height - randomY)
    let cropExtent = CGRect(x: randomX, y: randomY, width: randomWidth, height: randomHeight)

    let originalExtent = resultImage.extent
    let translation = CGAffineTransform(translationX: -randomX, y: -randomY)
    resultImage = resultImage.cropped(to: cropExtent).transformed(by: translation)

    resultAnnotations = resultAnnotations.compactMap { (annotation: Annotation) in

      let coords = annotation.coordinates
        .centerToBottomLeftCoords
        .flipCoordSystem(container: originalExtent)
        .applying(translation)
      
      return coords.intersects(resultImage.extent)
      ? Annotation(
        label: annotation.label,
        coordinates: coords
          .intersection(resultImage.extent)
          .flipCoordSystem(container: resultImage.extent)
          .bottomLeftToCenterCoords
      )
      : nil
    }
  }

}
