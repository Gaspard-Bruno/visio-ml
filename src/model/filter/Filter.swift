struct FilterResult: FilterInOut {
  var images: [ImageModel]
  var annotatedImages: [AnnotatedImageModel]
}

protocol FilterInOut {
  var images: [ImageModel] { get }
  var annotatedImages: [AnnotatedImageModel] { get }
}

protocol Filter {
  associatedtype Input: FilterInOut

  var parameters: Input { get set }

  func apply() -> FilterInOut
}
