import Combine
import Foundation

class DataStore: ObservableObject {

  @Published var workingFolder: URL?
  @Published var counter = 0
  @Published var annotatedImages: [AnnotatedImageModel] = []
  @Published var images: [ImageModel] = []
  @Published var selectedImage: ImageModel? {
    willSet {
      selectedLabel = nil
    }
  }

  @Published var selectedLabel: LabelModel!

  var selectedAnnotatedImage: AnnotatedImageModel? {
    guard
      let selectedImage = self.selectedImage
    else {
      return nil
    }
    return getAnnotatedImage(selectedImage)
  }

  func getAnnotatedImage(_ imageModel: ImageModel) -> AnnotatedImageModel {
    guard let annotatedImage = annotatedImages.first(where: { $0.imagefilename == imageModel.filename }) else {
      let newAnnotatedImage = AnnotatedImageModel(imagefilename: imageModel.filename, annotation: [])
      annotatedImages.append(newAnnotatedImage)
      return newAnnotatedImage
    }
    return annotatedImage
  }

  func setWorkingFolder(_ url: URL) {
    var isDirectory: ObjCBool = ObjCBool(false)
    let exists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
    guard exists && isDirectory.boolValue else {
      return
    }
    workingFolder = url
    loadJSON()
    refreshContents()
  }

  func loadJSON() {
    guard
      let url = workingFolder,
      let contents = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles]),
      let jsonFile = contents.first(where: { $0.lastPathComponent == "annotations.json" })
    else {
      return
    }
    annotatedImages = load(jsonFile)
  }

  func load<T: Decodable>(_ file: URL) -> T {
    let data: Data
    do {
      data = try Data(contentsOf: file)
    } catch {
      fatalError("Couldn't load \(file.absoluteString) from main bundle:\n\(error)")
    }
    do {
      let decoder = JSONDecoder()
      return try decoder.decode(T.self, from: data)
    } catch {
      fatalError("Couldn't parse \(file.absoluteString) as \(T.self):\n\(error)")
    }
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

  func flipVertically() {
    guard
      let image = selectedImage,
      let annotatedImage = selectedAnnotatedImage,
      let flipped = image.flipVertically()
    else {
        return
    }
    let annotatedFlipped = annotatedImage.flipVertically(withName: flipped.filename, height: flipped.ciImage.extent.height)
    annotatedImages.append(annotatedFlipped)
    images.append(flipped)
  }

  func flipHorizontally() {
    guard
      let image = selectedImage,
      let annotatedImage = selectedAnnotatedImage,
      let flipped = image.flipHorizontally()
    else {
        return
    }
    let annotatedFlipped = annotatedImage.flipHorizontally(withName: flipped.filename, width: flipped.ciImage.extent.width)
    annotatedImages.append(annotatedFlipped)
    images.append(flipped)
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
    getAnnotatedImage(image).annotation.removeAll { $0 == label }
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
