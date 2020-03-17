import Combine
import Foundation

class DataStore: ObservableObject {

  @Published var counter = 0
  @Published var images: [ImageModel] = []
  @Published var selectedImage: ImageModel!
  @Published var selected: LabelModel?

  var annotatedImages: [AnnotatedImageModel] {
    images.map { $0.annotated }
  }

  var annotatedImage: AnnotatedImageModel? {
    guard let selectedImage = selectedImage else {
      return nil
    }
    return selectedImage.annotated
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
