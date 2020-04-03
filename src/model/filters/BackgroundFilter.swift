import Combine
import Foundation
import CoreImage

extension DataStore {

  func applyBackgrounds(_ image: ImageModel) {
    image.applyBackgrounds(workspace.backgrounds, randomBgPosition: workspace.randomBgPosition)
    let annotated = getAnnotatedImage(image)
    let annotatedWithBg = annotated.applyBackgrounds(workspace.backgrounds)
    annotatedImages.append(contentsOf: annotatedWithBg)
  }
}

extension ImageModel {

  func applyBackgrounds(_ backgroundUrls: [URL], randomBgPosition: Bool) {
    for url in backgroundUrls {
      applyBackground(ImageModel(url: url), randomBgPosition: randomBgPosition)
    }
  }

  func applyBackground(_ bg: ImageModel, randomBgPosition: Bool) {
    let newUrl = url
      .deletingPathExtension()
      .appendingPathExtension(bg.filename)
    var withBg: CIImage
    if randomBgPosition {
      let bgSize = bg.ciImage.extent
      let lowBound = -bgSize.maxY + ciImage.extent.maxY * 2
      let upBound = bgSize.maxY - ciImage.extent.maxY * 2
      let randomY = CGFloat.random(in: min(lowBound, upBound)  ..< max(lowBound, upBound))
      let lowBoundX = -bgSize.maxX + ciImage.extent.maxX * 2
      let upBoundX = bgSize.maxX - ciImage.extent.maxX * 2
      let randomX = CGFloat.random(in: min(lowBoundX, upBoundX)  ..< max(lowBoundX, upBoundX))
      // print("max X: \(ciImage.extent.maxX) \n BG max X: \(bg.ciImage.extent.maxX) \n Random X: \(randomX)")
      let transformation = CGAffineTransform(translationX: randomX, y: randomY)
      let transformed = ciImage.transformed(by: transformation)
      withBg = transformed.composited(over: bg.ciImage)
    } else {
      let croppedBg = bg.ciImage.cropped(to: ciImage.extent)
      withBg = ciImage.composited(over: croppedBg)
    }

    let context = CIContext()
    guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
      return
    }
    do {
      try context.writePNGRepresentation(of: withBg, to: newUrl, format: .RGBA8, colorSpace: colorSpace)
    } catch {
      print("Error writing PNG.\n\n\(error.localizedDescription)")
      return
    }
  }

}

extension AnnotatedImageModel {
  
  func applyBackgrounds(_ backgroundUrls: [URL]) -> [AnnotatedImageModel] {
    backgroundUrls.map { bgUrl in
      let bgName = bgUrl.lastPathComponent
      let url = bgUrl.deletingLastPathComponent().appendingPathComponent(imagefilename).deletingPathExtension().appendingPathExtension(bgName)
      return applyBackground(withName: url.lastPathComponent)
    }
  }

  func applyBackground(withName name: String) -> AnnotatedImageModel {
    AnnotatedImageModel(imagefilename: name, annotation: annotation)
  }
}

extension LabelModel {
  func applyBackground() -> LabelModel {
    return self
  }
}
