import Combine
import Foundation

class DataStore: ObservableObject {

  @Published var counter = 0
  @Published var images: [ImageModel] = []
  @Published var selectedImage: ImageModel? {
    willSet {
      selectedLabel = nil
    }
  }

  @Published var selectedLabel: LabelModel!

  func deleteSelectedImage() {
    guard
      let image = selectedImage else {
        return
    }
    selectedImage = nil
    images.removeAll { $0 == image }
  }

  func deleteSelectedLabel() {
    guard
      let image = selectedImage,
      let label = selectedLabel
    else {
        return
    }
    selectedLabel = nil
    image.annotated.annotation.removeAll { $0 == label }
  }

  var annotatedImages: [AnnotatedImageModel] {
    images.map { $0.annotated }
  }

  var annotatedImage: AnnotatedImageModel? {
    guard let selectedImage = selectedImage else {
      return nil
    }
    return selectedImage.annotated
  }
  
  var selectedAnnotatedImage: AnnotatedImageModel {
    annotatedImage!
  }

  // HACK ALERT: Here to unstuck refreshing of the ImageInfo subview
  @Published var dummyToggle = false

  func saveJSON() {
    let url = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0].appendingPathComponent("annotations.json")
    guard let data = try? JSONEncoder().encode(annotatedImages) else {
      return
    }
    try! data.write(to: url)
  }
}
