import Combine
import CoreGraphics
import Foundation

class UserData: ObservableObject {

  @Published var images: [AnnotatedImage] = []
  @Published var selected: Int?

  var folderWatcher: DirectoryWatcher?

  var isImageSelected: Bool {
    selected == nil
  }
  
  var selectedImage: AnnotatedImage! {
    images[selected!]
  }
  
  func selectImage(_ id: String) {
    selected = images.firstIndex { $0.id == id }
  }

  func loadImages() {
    images.removeAll()
    images.append(AnnotatedImage(id: "paperclip"))
    images.append(AnnotatedImage(id: "heart.fill"))
  }
  
  func addArea(with rect: CGRect) {
    guard
      let i = selected
    else {
      return
    }
    let id = images[i].areas.reduce(-1) { max($0, $1.id) } + 1
    images[i].areas.append(
      Area(id: id, rect: rect)
    )
  }
  
  func startMovingArea(_ id: Int) {
    guard
      let i = selected,
      let areaIndex = images[i].areas.firstIndex(where: { $0.id == id })
    else {
      return
    }
    images[i].areas[areaIndex].isMoving = true
  }

  func moveArea(_ id: Int, to origin: CGPoint) {
    guard
      let i = selected,
      let areaIndex = images[i].areas.firstIndex(where: { $0.id == id })
    else {
      return
    }
    images[i].areas[areaIndex].rect.origin = origin
    images[i].areas[areaIndex].isMoving = false
  }
  
  func setWorkingDirectory(url: URL) {
    let directoryContents = try! FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
    let filesOnly = directoryContents.filter { !$0.hasDirectoryPath }
    print("Files: \(filesOnly.count)")
    for c in filesOnly {
      print("Content URL: \(c)")
    }

    guard let folderWatcher = DirectoryWatcher(url, callback: {
      print("changed!")
    }) else {
      return
    }
    self.folderWatcher = folderWatcher
  }
}
