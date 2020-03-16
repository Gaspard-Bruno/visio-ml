import Combine
import Foundation

class ImageModel: Identifiable, Equatable, Hashable, ObservableObject {

  var url: URL

  static func == (lhs: ImageModel, rhs: ImageModel) -> Bool {
    lhs.url == rhs.url
  }

  var filename: String {
    url.lastPathComponent
  }
  
  var id: String {
    "\(url)"
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(url)
  }
  
  init(url: URL) {
    self.url = url
  }

  static var specimen: ImageModel {
    //ImageModel(url: Bundle.main.url(forResource: "cat-and-dog", withExtension: "png", subdirectory: "samples")!)
    ImageModel(url: Bundle.main.url(forResource: "cat-and-dog", withExtension: "png")!)
  }
}
