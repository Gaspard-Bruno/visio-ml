import CoreImage

struct FlipFilter: Filter {

  struct Input: FilterInOut {
    var images: [ImageModel]
    var annotatedImages: [ImageAnnotationModel]
    var workspace: WorkspaceModel
  }
  
  var parameters: Input
  
  var horizontal: Bool {
    parameters.workspace.flipHorizonal
  }

  var vertical: Bool {
    parameters.workspace.flipVertical
  }

  var doubleFlip: Bool {
    parameters.workspace.doubleFlip
  }

  func apply(image: ImageModel, annotated: ImageAnnotationModel) -> FilterResult {
    var resultingImages: [ImageModel] = []
    var resultingAnnotated: [ImageAnnotationModel] = []

    if horizontal, let flipped = image.flipHorizontally() {
      resultingImages.append(flipped)
      let annotatedFlipped = annotated.flipHorizontally(withName: flipped.filename, width: flipped.ciImage.extent.width)
      resultingAnnotated.append(annotatedFlipped)
      DispatchQueue.main.async {
        self.parameters.workspace.processedFiles += 1
      }

      if vertical, doubleFlip, let doubleFlipped = flipped.flipVertically()  {
        resultingImages.append(doubleFlipped)
        let annotatedFlipped = annotatedFlipped.flipVertically(withName: doubleFlipped.filename, height: doubleFlipped.ciImage.extent.height)
        resultingAnnotated.append(annotatedFlipped)
        DispatchQueue.main.async {
          self.parameters.workspace.processedFiles += 1
        }
      }
    }
    if vertical, let flipped = image.flipVertically()  {
      resultingImages.append(flipped)
      let annotatedFlipped = annotated.flipVertically(withName: flipped.filename, height: flipped.ciImage.extent.height)
      resultingAnnotated.append(annotatedFlipped)
      DispatchQueue.main.async {
        self.parameters.workspace.processedFiles += 1
      }
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

extension ImageAnnotationModel {
  func flipVertically(withName name: String, height: CGFloat) -> ImageAnnotationModel {
    let flippedAnnotation = annotation.map { $0.flipVertically(withHeight: height) }
    return ImageAnnotationModel(imagefilename: name, annotation: flippedAnnotation)
  }

  func flipHorizontally(withName name: String, width: CGFloat) -> ImageAnnotationModel {
    let flippedAnnotation = annotation.map { $0.flipHorizontally(withWidth: width) }
    return ImageAnnotationModel(imagefilename: name, annotation: flippedAnnotation)
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
