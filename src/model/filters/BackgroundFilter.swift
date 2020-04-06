import CoreImage

struct BackgroundFilter: Filter {
  
  struct Input: FilterInOut {
    var images: [ImageModel]
    var annotatedImages: [ImageAnnotationModel]
    var backgrounds: [URL]
    var randomBgPosition: Bool
  }
  
  var parameters: Input
  
  func apply(image: ImageModel, annotated: ImageAnnotationModel) -> FilterResult {
    var resultingImages: [ImageModel] = []
    var resultingAnnotated: [ImageAnnotationModel] = []
    
    for url in parameters.backgrounds {
      let (imageOut, annotationOut) = applyBackground(image, annotated, url)
      resultingImages.append(imageOut)
      resultingAnnotated.append(annotationOut)
    }
    
    return FilterResult(images: resultingImages, annotatedImages: resultingAnnotated)
  }
  
  
  func applyBackground(_ image: ImageModel, _ annotation: ImageAnnotationModel, _ bgUrl: URL)  -> (ImageModel, ImageAnnotationModel) {

    var resultingImage: ImageModel
    var resultingAnnotation: ImageAnnotationModel
    var resultingCiImage: CIImage

    let newUrl = image.url
      .deletingPathExtension()
      .appendingPathExtension(bgUrl.lastPathComponent)

    let bgImage = CIImage(contentsOf: bgUrl)!

    if parameters.randomBgPosition {
      let bgSize = bgImage.extent
      let upBoundX = bgSize.maxX - image.ciImage.extent.maxX
      let randomX = CGFloat.random(in: 0 ..< upBoundX)
      let upBoundY = bgSize.maxY - image.ciImage.extent.maxY
      let randomY = CGFloat.random(in: 0 ..< upBoundY)
      let transformation = CGAffineTransform(translationX: randomX, y: randomY)
      
      let transformed = image.ciImage.transformed(by: transformation)
      resultingCiImage = transformed.composited(over: bgImage)

      // Crop to the max of the synthetic image???
      // withBg = withBg.cropped(to: bg.ciImage.extent)
      var regions: [LabelModel] = []
      for area in annotation.annotation {
        let center = CGPoint(x: area.coordinates.x, y: area.coordinates.y)
        let newCenter = center.applying(transformation)
        let coordinates = LabelModel.CoordinatesModel(y: newCenter.y, x: newCenter.x, height: area.coordinates.height, width: area.coordinates.width)
        let label = LabelModel(label: area.label, coordinates: coordinates)
        regions.append(label)
      }
      resultingAnnotation = ImageAnnotationModel(imagefilename: newUrl.lastPathComponent, annotation: regions)
    } else {
      let croppedBg = bgImage.cropped(to: image.ciImage.extent)
      resultingCiImage = image.ciImage.composited(over: croppedBg)
      resultingAnnotation = ImageAnnotationModel(imagefilename: newUrl.lastPathComponent, annotation: annotation.annotation)
    }
    
    let context = CIContext()
    let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    do {
      try context.writePNGRepresentation(of: resultingCiImage, to: newUrl, format: .RGBA8, colorSpace: colorSpace)
    } catch {
      print("Error writing PNG.\n\n\(error.localizedDescription)")
    }
    
    resultingImage = ImageModel(url: newUrl)
    return (resultingImage, resultingAnnotation)
  }
}
