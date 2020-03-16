import Combine
import Foundation

class DataStore: ObservableObject {
  @Published var counter = 0
  @Published var annotatedImage: AnnotatedImageModel = AnnotatedImageModel.specimen
  @Published var selected: LabelModel?
  @Published var images: [ImageModel] = [ImageModel.specimen]
  @Published var selectedImage: ImageModel! = nil
  
  func saveJSON() {
    let url = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0].appendingPathComponent("annotations.json")
    guard let data = try? JSONEncoder().encode(annotatedImage) else {
      return
    }
    try! data.write(to: url)
  }
}
