import Combine
import Foundation

extension DataStore {

  func applyFilters() {
    
    let startingImages: [ImageModel]
    let startingAnnotatedImages: [ImageAnnotationModel]
    if workspace.selectionOnly {
      startingImages = self.selectedImagesArray
      startingAnnotatedImages = self.matchingSelectedAnnotatedImages
    } else {
      startingImages = self.images
      startingAnnotatedImages = self.matchingAnnotatedImages
    }
    
    let flipFilter = FlipFilter(parameters: .init(images: startingImages, annotatedImages: startingAnnotatedImages, workspace: workspace))
    let flipResult = flipFilter.apply()

    let backgroundFilter = BackgroundFilter(parameters: .init(images: flipResult.images, annotatedImages: flipResult.annotatedImages, workspace: workspace))
    let backgroundFilterResult = backgroundFilter.apply()

    let backgroundFilter2 = BackgroundFilter(parameters: .init(images: startingImages, annotatedImages: startingAnnotatedImages, workspace: workspace))
    let backgroundFilterResult2 = backgroundFilter2.apply()
    
    annotatedImages.append(contentsOf: flipResult.annotatedImages)
    annotatedImages.append(contentsOf: backgroundFilterResult.annotatedImages)
    annotatedImages.append(contentsOf: backgroundFilterResult2.annotatedImages)

  }
}
