struct IdentityFilter: Filter {

  struct Input: FilterInOut {
    var images: [ImageModel]
    var annotatedImages: [ImageAnnotationModel]
  }
  
  var parameters: Input
}
