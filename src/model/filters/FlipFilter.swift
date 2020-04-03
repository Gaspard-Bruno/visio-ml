import CoreImage

struct FlipFilter: Filter {

  struct Input: FilterInOut {
    var images: [ImageModel]
    var annotatedImages: [AnnotatedImageModel]
    var horizontal: Bool
    var vertical: Bool
  }
  
  var parameters: Input

  func apply() -> FilterInOut {
    var resultingImages: [ImageModel] = []
    var resultingAnnotated: [AnnotatedImageModel] = []
    for i in parameters.images.indices {
      let result = apply(image: parameters.images[i], annotated: parameters.annotatedImages[i])
      resultingImages.append(contentsOf: result.images)
      resultingAnnotated.append(contentsOf: result.annotatedImages)
    }
    return FilterResult(images: resultingImages, annotatedImages: resultingAnnotated)
  }

  func apply(image: ImageModel, annotated: AnnotatedImageModel) -> FilterResult {
    var resultingImages: [ImageModel] = []
    var resultingAnnotated: [AnnotatedImageModel] = []

    if parameters.horizontal, let flipped = image.flipHorizontally() {
      resultingImages.append(flipped)
      let annotatedFlipped = annotated.flipHorizontally(withName: flipped.filename, width: flipped.ciImage.extent.width)
      resultingAnnotated.append(annotatedFlipped)
      if parameters.vertical, let doubleFlipped = flipped.flipVertically()  {
        resultingImages.append(doubleFlipped)
        let annotatedFlipped = annotatedFlipped.flipVertically(withName: doubleFlipped.filename, height: doubleFlipped.ciImage.extent.height)
        resultingAnnotated.append(annotatedFlipped)
      }
    }
    if parameters.vertical, let flipped = image.flipVertically()  {
      resultingImages.append(flipped)
      let annotatedFlipped = annotated.flipVertically(withName: flipped.filename, height: flipped.ciImage.extent.height)
      resultingAnnotated.append(annotatedFlipped)
    }
    return FilterResult(images: resultingImages, annotatedImages: resultingAnnotated)
  }
}

extension ImageModel {

  func flipVertically() -> ImageModel? {
    let newUrl = url.deletingPathExtension().appendingPathExtension("v_flipped").appendingPathExtension("png")
    let flipped = ciImage.transformed(by: .init(scaleX: 1, y: -1))
    let context = CIContext()
    guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
      return nil
    }
    do {
      try context.writePNGRepresentation(of: flipped, to: newUrl, format: .RGBA8, colorSpace: colorSpace)
    } catch {
      return nil
    }
    return ImageModel(url: newUrl)
  }

  func flipHorizontally() -> ImageModel? {
    let newUrl = url.deletingPathExtension().appendingPathExtension("h_flipped").appendingPathExtension("png")
    let flipped = ciImage.transformed(by: .init(scaleX: -1, y: 1))
    let context = CIContext()
    guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
      return nil
    }
    do {
      try context.writePNGRepresentation(of: flipped, to: newUrl, format: .RGBA8, colorSpace: colorSpace)
    } catch {
      return nil
    }
    return ImageModel(url: newUrl)
  }
}

extension AnnotatedImageModel {
  func flipVertically(withName name: String, height: CGFloat) -> AnnotatedImageModel {
    let flippedAnnotation = annotation.map { $0.flipVertically(withHeight: height) }
    return AnnotatedImageModel(imagefilename: name, annotation: flippedAnnotation)
  }

  func flipHorizontally(withName name: String, width: CGFloat) -> AnnotatedImageModel {
    let flippedAnnotation = annotation.map { $0.flipHorizontally(withWidth: width) }
    return AnnotatedImageModel(imagefilename: name, annotation: flippedAnnotation)
  }
}

extension LabelModel {
  func flipVertically(withHeight height: CGFloat) -> LabelModel {
    LabelModel(label: label, coordinates: CoordinatesModel(
      y: height - coordinates.y,
      x: coordinates.x,
      height: coordinates.height,
      width: coordinates.width
    ))
  }

  func flipHorizontally(withWidth width: CGFloat) -> LabelModel {
    LabelModel(label: label, coordinates: CoordinatesModel(
      y: coordinates.y,
      x: width - coordinates.x,
      height: coordinates.height,
      width: coordinates.width
    ))
  }
}
