struct IdentityFilter: Filter {

  struct Input: FilterInOut {
    var images: [ImageModel]
    var annotatedImages: [AnnotatedImageModel]
  }
  
  var parameters: Input

  func apply() -> FilterInOut {
    FilterResult(images: parameters.images, annotatedImages: parameters.annotatedImages)
  }
}
