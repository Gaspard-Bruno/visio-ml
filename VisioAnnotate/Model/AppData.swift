import Combine
import Foundation

class AppData: ObservableObject {

  static let shared = AppData()
  
  @Published var navigationState = NavigationState()
  @Published var annotatedImages = [AnnotatedImage]()
  @Published var workingFolder: URL?
  @Published var currentModal: String?

  @Published var annotationCounter = 0 // For "Untitled #" labels
  @Published var viewportSize: CGSize = CGSize.zero

  var currentScaleFactor: CGFloat? {
    guard let image = activeImage else {
      return nil
    }
    return viewportSize.width / image.ciImage.extent.size.width
  }
  
  var pendingImages: Int {
    annotatedImages.reduce(0) {
      $0 + ($1.isEnabled ? 0 : 1)
    }
  }

  private var folderWatcher: DirectoryWatcher?

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
    navigationState.isNavigatorVisible.toggle()
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
    loadJSON()
    refreshImages()
    navigationState.isNavigatorVisible = true
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
