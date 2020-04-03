import Combine
import Foundation

extension DataStore {

  func applyFilters() {
    let flipFilter = FlipFilter(parameters: .init(images: images, annotatedImages: matchingAnnotatedImages, horizontal: workspace.flipHorizonal, vertical: workspace.flipVertical))
    let flipResult = flipFilter.apply()
    annotatedImages.append(contentsOf: flipResult.annotatedImages)
//    let idFilter = IdentityFilter(parameters: .init(images: flipResult.images, annotatedImages: flipResult.annotatedImages))
//    let _ = idFilter.apply()
    for image in flipResult.images {
      applyBackgrounds(image)
    }
    for image in images {
      applyBackgrounds(image)
    }
  }
}
