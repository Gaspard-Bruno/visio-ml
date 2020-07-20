import Foundation
import CoreImage

extension SyntheticsTask {

  func applyBackground() {

    guard let backgroundsUrl = settings.backgrounds else {
      // FIXME: this produces a copy of the original image with no background, better just skip this entire filter
      return
    }

    let backgroundUrls = try! FileManager.default.contentsOfDirectory(at: backgroundsUrl, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles]).filter { $0.path.lowercased().hasSuffix(".png") }
    let backgroundUrl = backgroundUrls[Int.random(in: 0 ..< backgroundUrls.count)]

    var bgImage = CIImage(contentsOf: backgroundUrl)!
        
    // If background doesn't fit, we scale it up
    let imageSize = resultImage.extent.size
    var bgSize = bgImage.extent.size
    if imageSize.width > bgSize.width || imageSize.height > bgSize.height {
      let bgScaleX: CGFloat
      let bgScaleY: CGFloat
      if imageSize.width > bgSize.width {
        bgScaleX = imageSize.width / bgSize.width
      } else {
        bgScaleX = 1
      }
      if imageSize.height > bgSize.height {
        bgScaleY = imageSize.height / bgSize.height
      } else {
        bgScaleY = 1
      }
      bgImage = bgImage.transformed(by: CGAffineTransform(scaleX: bgScaleX, y: bgScaleY))
      bgSize = bgImage.extent.size
    }

    let upBoundX = bgSize.width - imageSize.width
    let upBoundY = bgSize.height - imageSize.height
    let randomX = CGFloat.random(in: 0 ... upBoundX)
    let randomY = CGFloat.random(in: 0 ... upBoundY)

    let translateTransform = CGAffineTransform(translationX: randomX, y: randomY)
    let originalExtent = resultImage.extent
    resultImage = resultImage.transformed(by: translateTransform).composited(over: bgImage)

    resultAnnotations = resultAnnotations.map { (annotation: Annotation) in
      let newCoords = annotation.coordinates
        .flipCoordSystem(container: originalExtent)
        .applying(translateTransform)
        .flipCoordSystem(container: resultImage.extent)
      return Annotation(label: annotation.label, coordinates: newCoords)
    }
  }

}
