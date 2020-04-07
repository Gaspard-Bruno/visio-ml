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
    let width = image.ciImage.extent.maxX
    let height = image.ciImage.extent.maxY
    let bgSize = bgImage.extent

    if parameters.randomBgPosition {
      let upBoundX = bgSize.maxX - width
      let randomX = CGFloat.random(in: 0 ..< upBoundX)
      let upBoundY = bgSize.maxY - height
      let randomY = CGFloat.random(in: 0 ..< upBoundY)
      let transformation = CGAffineTransform(translationX: randomX, y: randomY)
print("Random: \(randomX), \(randomY)")
      let transformed = image.ciImage.transformed(by: transformation)
      resultingCiImage = transformed.composited(over: bgImage)

      var newLabels: [LabelModel] = []
      for label in annotation.annotation {
        let newCenter = CGPoint(x: label.coordinates.x, y: label.coordinates.y + (bgSize.maxY - height)).applying(CGAffineTransform(translationX: transformation.tx, y: -transformation.ty))
        let newCoordinates = LabelModel.CoordinatesModel(y: newCenter.y, x: newCenter.x, height: label.coordinates.height, width: label.coordinates.width)
        let newLabel = LabelModel(label: label.label, coordinates: newCoordinates)
        newLabels.append(newLabel)
      }
      resultingAnnotation = ImageAnnotationModel(imagefilename: newUrl.lastPathComponent, annotation: newLabels)

    } else {
      let croppedBg = bgImage.cropped(to: image.ciImage.extent)
      resultingCiImage = image.ciImage.composited(over: croppedBg)
      
      var newLabels: [LabelModel] = []
      for label in annotation.annotation {
        let newCenter = CGPoint(x: label.coordinates.x, y: label.coordinates.y)
        let newCoordinates = LabelModel.CoordinatesModel(y: newCenter.y, x: newCenter.x, height: label.coordinates.height, width: label.coordinates.width)
        let newLabel = LabelModel(label: label.label, coordinates: newCoordinates)
        newLabels.append(newLabel)
      }
      resultingAnnotation = ImageAnnotationModel(imagefilename: newUrl.lastPathComponent, annotation: newLabels)
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
