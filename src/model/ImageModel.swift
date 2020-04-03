import Combine
import Foundation
import AppKit
import CoreImage

class ImageModel: Identifiable, Equatable, Hashable, ObservableObject {

  @Published var url: URL
  
  var ciImage: CIImage {
    CIImage(contentsOf: url)!
  }
  var nsImage: NSImage {
    NSImage(byReferencing: url)
  }
  
  var size: CGSize {
    ciImage.extent.size
  }
  
  var aspectRatio: CGFloat {
    size.width / size.height
  }

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
