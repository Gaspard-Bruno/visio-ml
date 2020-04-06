struct FilterResult: FilterInOut {
  var images: [ImageModel]
  var annotatedImages: [ImageAnnotationModel]
}

protocol FilterInOut {
  var images: [ImageModel] { get }
  var annotatedImages: [ImageAnnotationModel] { get }
}

protocol Filter {
  associatedtype Input: FilterInOut

  var parameters: Input { get set }

  func apply() -> FilterInOut
  func apply(image: ImageModel, annotated: ImageAnnotationModel) -> FilterResult
}

extension Filter {
  func apply() -> FilterInOut {
    var resultingImages: [ImageModel] = []
    var resultingAnnotated: [ImageAnnotationModel] = []
    for i in parameters.images.indices {
      let result = apply(image: parameters.images[i], annotated: parameters.annotatedImages[i])
      resultingImages.append(contentsOf: result.images)
      resultingAnnotated.append(contentsOf: result.annotatedImages)
    }
    return FilterResult(images: resultingImages, annotatedImages: resultingAnnotated)
  }

  func apply(image: ImageModel, annotated: ImageAnnotationModel) -> FilterResult {
    FilterResult(images: [image], annotatedImages: [annotated])
  }
}
