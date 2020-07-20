import Foundation
import CoreImage

extension SyntheticsTask {

  func applyCutout() {
    let randW = CGFloat.random(in: 0 ..< resultImage.extent.width)
    let randH = CGFloat.random(in: 0 ..< resultImage.extent.height)
    let randX = CGFloat.random(in: 0 ..< (resultImage.extent.width - randW))
    let randY = CGFloat.random(in: 0 ..< (resultImage.extent.height - randH))

    let cutoutExtent = CGRect(
        origin: CGPoint(
            x: randX,
            y: randY
        ),
        size: CGSize(
            width: randW,
            height: randH
        )
    )
    let cutout = CIImage(color: .gray).cropped(to: cutoutExtent)

    resultImage = cutout.composited(over: resultImage)

    resultAnnotations = resultAnnotations.compactMap { (annotation: Annotation) in

      let coords = annotation.coordinates
        .centerToBottomLeftCoords
        .flipCoordSystem(container: resultImage.extent)

      let exclusion = coords.exclusion(cutoutExtent)
      if exclusion.isNull {
        return nil
      }
      return Annotation(
        label: annotation.label,
        coordinates:
          exclusion
            .flipCoordSystem(container: resultImage.extent)
            .bottomLeftToCenterCoords
      )
    }
  }
}
