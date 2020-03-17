import Combine
import Foundation
import AppKit
import CoreImage

class ImageModel: Identifiable, Equatable, Hashable, ObservableObject {

  @Published var url: URL
  @Published var currentScaledSize = CGSize(width: 0, height: 0)
  @Published var annotated: AnnotatedImageModel
  
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

  var currentScale: CGFloat {
    currentScaledSize.width / size.width
  }

  static func == (lhs: ImageModel, rhs: ImageModel) -> Bool {
    lhs.url == rhs.url && lhs.currentScaledSize == rhs.currentScaledSize
  }

  var filename: String {
    url.lastPathComponent
  }
  
  var id: String {
    "\(url)"
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(url)
    hasher.combine(currentScaledSize.width)
    hasher.combine(currentScaledSize.height)
    hasher.combine(annotated)
  }
  
  init(url: URL) {
    self.url = url
    self.annotated = AnnotatedImageModel(imagefilename: url.lastPathComponent, annotation: [])
  }

  static var specimen: ImageModel {
    //ImageModel(url: Bundle.main.url(forResource: "cat-and-dog", withExtension: "png", subdirectory: "samples")!)
    ImageModel(url: Bundle.main.url(forResource: "cat-and-dog", withExtension: "png")!)
  }
}
