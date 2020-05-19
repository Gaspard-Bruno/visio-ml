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
    
    var total = startingImages.count
    if workspace.flipVertical {
      total += startingImages.count
    }
    if workspace.flipHorizonal {
      total += startingImages.count
    }
    if workspace.doubleFlip {
      total += startingImages.count
    }
    if workspace.everyBackground {
      total += total * workspace.backgrounds.count
    }
    workspace.totalFiles = total
    workspace.processedFiles = startingImages.count
    
    DispatchQueue.global(qos: .userInteractive).async {
      let workspace = self.workspace

      let flipFilter = FlipFilter(parameters: .init(images: startingImages, annotatedImages: startingAnnotatedImages, workspace: workspace))
      let flipResult = flipFilter.apply()
      
      let backgroundFilter = BackgroundFilter(parameters: .init(images: flipResult.images, annotatedImages: flipResult.annotatedImages, workspace: workspace))
      let backgroundFilterResult = backgroundFilter.apply()

      let backgroundFilter2 = BackgroundFilter(parameters: .init(images: startingImages, annotatedImages: startingAnnotatedImages, workspace: workspace))
      let backgroundFilterResult2 = backgroundFilter2.apply()
      
      DispatchQueue.main.async {
        self.annotatedImages.append(contentsOf: flipResult.annotatedImages)
        self.annotatedImages.append(contentsOf: backgroundFilterResult.annotatedImages)
        self.annotatedImages.append(contentsOf: backgroundFilterResult2.annotatedImages)
      }
      DispatchQueue.main.async {
        self.dummyToggle.toggle()
      }
    }
  }
}
