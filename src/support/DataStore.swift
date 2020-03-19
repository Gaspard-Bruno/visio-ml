import Combine
import Foundation

class DataStore: ObservableObject {

  @Published var workingFolder: URL?
  @Published var counter = 0
  @Published var images: [ImageModel] = []
  @Published var selectedImage: ImageModel? {
    willSet {
      selectedLabel = nil
    }
  }

  @Published var selectedLabel: LabelModel!

  func setWorkingFolder(_ url: URL) {
    var isDirectory: ObjCBool = ObjCBool(false)
    let exists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
    guard exists && isDirectory.boolValue else {
      return
    }
    workingFolder = url
    refreshContents()
  }

  func refreshContents() {
    guard let url = workingFolder else {
      return
    }
    let contents = try! FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles])
    let pngs = contents.filter { $0.path.lowercased().hasSuffix(".png") }
    for imageUrl in pngs {
      guard images.first(where: { $0.url == imageUrl }) == nil else {
        continue
      }
      images.append(ImageModel(url: imageUrl))
    }
  }

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
    guard let folderUrl = workingFolder else {
      return
    }
    // let folderUrl = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
    let url = folderUrl.appendingPathComponent("annotations.json")
    guard let data = try? JSONEncoder().encode(annotatedImages) else {
      return
    }
    try! data.write(to: url)
  }
}
