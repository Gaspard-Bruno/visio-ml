import Combine
import Foundation

extension DataStore {

  func applyFilters() {
    let flipFilter = FlipFilter(parameters: .init(images: images, annotatedImages: matchingAnnotatedImages, horizontal: workspace.flipHorizonal, vertical: workspace.flipVertical))
    let flipResult = flipFilter.apply()

    let backgroundFilter = BackgroundFilter(parameters: .init(images: flipResult.images, annotatedImages: flipResult.annotatedImages, backgrounds: workspace.backgrounds, randomBgPosition: workspace.randomBgPosition))
    let backgroundFilterResult = backgroundFilter.apply()

    let backgroundFilter2 = BackgroundFilter(parameters: .init(images: images, annotatedImages: annotatedImages, backgrounds: workspace.backgrounds,  randomBgPosition: workspace.randomBgPosition))
    let backgroundFilterResult2 = backgroundFilter2.apply()
    
    annotatedImages.append(contentsOf: flipResult.annotatedImages)
    annotatedImages.append(contentsOf: backgroundFilterResult.annotatedImages)
    annotatedImages.append(contentsOf: backgroundFilterResult2.annotatedImages)

  }
}
