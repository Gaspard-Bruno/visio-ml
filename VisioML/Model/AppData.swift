import Combine
import Foundation
import CoreImage

class AppData: ObservableObject {

  static let shared = AppData()
  
  @Published var navigation = NavigationState()
  @Published var settings = WorkspaceSettings() {
    didSet {
      guard let dirUrl = workingFolder?.appendingPathComponent(".visioannotate") else {
          return
      }
      var isDirectory: ObjCBool = ObjCBool(false)
      let exists = FileManager.default.fileExists(atPath: dirUrl.path, isDirectory: &isDirectory)
      if !exists || !isDirectory.boolValue {
        do {
          try FileManager.default.createDirectory(at: dirUrl, withIntermediateDirectories: false)
        } catch {
          print("\(error.localizedDescription)")
          return
        }
      }
      let url = dirUrl.appendingPathComponent("workspace.json")
      guard let data = try? JSONEncoder().encode(settings) else {
        return
      }
      try! data.write(to: url)
    }
  }
  @Published var annotatedImages = [AnnotatedImage]()
  @Published var workingFolder: URL?
  @Published var viewportSize: CGSize = CGSize.zero

  var currentScaleFactor: CGFloat? {
    guard let image = activeImage, let ciImage = CIImage(contentsOf: image.url) else {
      return nil
    }
    return viewportSize.width / ciImage.extent.size.width
  }
  
  var pendingImages: Int {
    annotatedImages.reduce(0) {
      $0 + ($1.isEnabled ? 0 : 1)
    }
  }

  var folderWatcher: DirectoryWatcher?

  var activeImage: AnnotatedImage? {
    guard let activeImageIndex = activeImageIndex else {
      return nil
    }
    return annotatedImages[activeImageIndex]
  }

  var activeImageIndex: Int? {
    annotatedImages.firstIndex(where: { $0.isActive == true } )
  }

  func toggleNavigator() {
    navigation.isNavigatorVisible.toggle()
  }
  
  func activateImage(_ annotatedImage: AnnotatedImage) {
    guard let index = annotatedImages.firstIndex(where: { $0.id == annotatedImage.id }) else {
      return
    }
    if let activeImageIndex = activeImageIndex {
      annotatedImages[activeImageIndex].isActive.toggle()
    }
    annotatedImages[index].isActive.toggle()
  }

  func toggleImage(_ annotatedImage: AnnotatedImage) {
    guard let index = annotatedImages.firstIndex(where: { $0.id == annotatedImage.id }) else {
      return
    }
    annotatedImages[index].isMarked.toggle()
  }

  func unsetWorkingFolder() {
    annotatedImages = []
    settings = WorkspaceSettings()
    workingFolder = nil
  }
  
  func setWorkingFolder(_ url: URL) {
    var isDirectory: ObjCBool = ObjCBool(false)
    let exists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
    guard exists && isDirectory.boolValue else {
      return
    }
    guard let folderWatcher = DirectoryWatcher(url, callback: {
      self.refreshImages()
    }) else {
      return
    }
    self.folderWatcher = folderWatcher
    workingFolder = url
    loadSettings()
    loadJSON()
    refreshImages()
    navigation.isNavigatorVisible = true
    if annotatedImages.count > 0 {
      annotatedImages[0].isActive = true
    }
  }

  func refreshImages() {
    guard let folder = workingFolder else {
      return
    }
    let files = try! FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles])
    let pngFiles = files.filter { $0.path.lowercased().hasSuffix(".png") }
    
    // Remove deleted images
    for image in annotatedImages {
      // Chceck if image is in dir contents
      if pngFiles.first(where: { $0 == image.url }) == nil {
        // Remove image from internal array
        annotatedImages.removeAll { $0.url == image.url }
      }
    }
    // Add new images only
    for file in pngFiles {
      guard annotatedImages.first(where: { $0.url == file }) == nil else {
        // Image was already there, leave as is
        continue
      }
      // Add the new image
      annotatedImages.append(AnnotatedImage(url: file))
    }
    // TODO: Handle renames
  }

  func loadSettings() {
    guard
      let url = workingFolder?.appendingPathComponent(".visioannotate") else {
        return
    }
    var isDirectory: ObjCBool = ObjCBool(false)
    let exists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
    guard
      exists && isDirectory.boolValue,
      let contents = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles]),
      let jsonFile = contents.first(where: { $0.lastPathComponent == "workspace.json" })
    else {
      return
    }
    settings = load(jsonFile) ?? WorkspaceSettings()
  }

  func loadJSON() {
    guard
      let url = workingFolder,
      let contents = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles]),
      let jsonFile = contents.first(where: { $0.lastPathComponent == "annotations.json" })
    else {
      return
    }
    annotatedImages = load(jsonFile) ?? []
  }

  func load<T: Decodable>(_ file: URL) -> T? {
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
      return nil
    }
  }

  func saveJSON() {
    guard let folderUrl = workingFolder else {
      return
    }
    let url = folderUrl.appendingPathComponent("annotations.json")
    guard let data = try? JSONEncoder().encode(annotatedImages) else {
      return
    }
    try! data.write(to: url)
  }
  
  func removeActiveAnnotation() {
    annotatedImages.removeActiveAnnotation()
  }

  func activateNextImage() {
    annotatedImages.activateNext()
  }

  func activatePreviousImage() {
    annotatedImages.activateNext(reverse: true)
  }
}
