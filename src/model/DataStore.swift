import Combine
import Foundation

class DataStore: ObservableObject {

  @Published var workingFolder: URL?
  @Published var workspace = WorkspaceModel() {
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
      guard let data = try? JSONEncoder().encode(workspace) else {
        return
      }
      try! data.write(to: url)
    }
  }

  @Published var counter = 0 // For "Untitled #" labels

  @Published var images: [ImageModel] = []
  @Published var annotatedImages: [ImageAnnotationModel] = []

  @Published var viewportSize: CGSize?

  var currentScaleFactor: CGFloat? {
    guard let viewportSize = self.viewportSize, let image = selectedImage else {
      return nil
    }
    return viewportSize.width / image.size.width
  }
  
  @Published var selectedImages: Set<ImageModel> = [] {
    willSet {
      selectedLabel = nil
    }
  }

  var selectedImage: ImageModel? {
    selectedImages.count == 1 ? selectedImages.first! : nil
  }

  @Published var selectedLabel: LabelModel!

  private var folderWatcher: DirectoryWatcher?

  var matchingAnnotatedImages: [ImageAnnotationModel] {
    images.map {
      getAnnotatedImage($0)
    }
  }

  var selectedImagesArray: [ImageModel] {
    images.filter {
      selectedImages.contains($0)
    }
  }

  var matchingSelectedAnnotatedImages: [ImageAnnotationModel] {
    selectedImagesArray.map {
      getAnnotatedImage($0)
    }
  }

  var selectedAnnotatedImage: ImageAnnotationModel? {
    guard
      let selectedImage = self.selectedImage
    else {
      return nil
    }
    return getAnnotatedImage(selectedImage)
  }

  func getAnnotatedImage(_ imageModel: ImageModel) -> ImageAnnotationModel {
    guard let annotatedImage = annotatedImages.first(where: { $0.imagefilename == imageModel.filename }) else {
      let newAnnotatedImage = ImageAnnotationModel(imagefilename: imageModel.filename, annotation: [])
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
    guard let folderWatcher = DirectoryWatcher(url, callback: {
      self.refreshContents()
    }) else {
      return
    }
    self.folderWatcher = folderWatcher
    workingFolder = url
    loadWorkspace()
    loadJSON()
    refreshContents()
  }

  func loadWorkspace() {
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
    workspace = load(jsonFile)
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
    
    // Remove deleted images
    for image in images {
      // Chceck if image is in dir contents
      if pngs.first(where: { $0 == image.url }) == nil {
        // If removing the currently selected one, unselect
        if selectedImages.contains(image) {
          selectedImages.remove(image)
        }
        // Check if an annotation was generated for this image
        if let annotated = annotatedImages.first(where: { $0.imagefilename == image.filename }) {
          // Delete annotation
          annotatedImages.removeAll { $0 == annotated }
          // TODO: Figure out away to keep non-empty annotations (ghost images?)
        }
        // Remove image from internal array
        images.removeAll { $0 == image }
      }
    }
    // Add new images only
    for imageUrl in pngs {
      guard images.first(where: { $0.url == imageUrl }) == nil else {
        // Image was already there, leave as is
        continue
      }
      // Add the new image
      images.append(ImageModel(url: imageUrl))
    }
    // TODO: Look for a way to handle renames
  }

  //func deleteSelectedImage() {
  //  guard
  //    let image = selectedImage else {
  //      return
  //  }
  //  selectedImage = nil
  //  images.removeAll { $0 == image }
  //}

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
