import Combine
import Foundation

extension DataStore {

  func applyFilters() {
    let flipFilter = FlipFilter(parameters: .init(images: images, annotatedImages: matchingAnnotatedImages, workspace: workspace))
    let flipResult = flipFilter.apply()

    let backgroundFilter = BackgroundFilter(parameters: .init(images: flipResult.images, annotatedImages: flipResult.annotatedImages, workspace: workspace))
    let backgroundFilterResult = backgroundFilter.apply()

    let backgroundFilter2 = BackgroundFilter(parameters: .init(images: images, annotatedImages: annotatedImages, workspace: workspace))
    let backgroundFilterResult2 = backgroundFilter2.apply()
    
    annotatedImages.append(contentsOf: flipResult.annotatedImages)
    annotatedImages.append(contentsOf: backgroundFilterResult.annotatedImages)
    annotatedImages.append(contentsOf: backgroundFilterResult2.annotatedImages)

  }
}
