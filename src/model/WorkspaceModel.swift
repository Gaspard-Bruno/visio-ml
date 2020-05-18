import Combine
import Foundation

class WorkspaceModel: Codable, ObservableObject {

  init() { }

  @Published var selectionOnly = false
  @Published var dummyToggle = false
  @Published var processedFiles = 0
  @Published var totalFiles = 0

  @Published var noBackground = true
  @Published var everyBackground = true
  @Published var randomPosition = true
  @Published var randomScale = true
  @Published var keepAspectRatio = true
  @Published var flipHorizonal = true
  @Published var flipVertical = true
  @Published var doubleFlip = true
  @Published var noiseLayer = true

  @Published var backgroundsFolder: URL?

  enum CodingKeys: String, CodingKey {
      case noBackground
      case everyBackground
      case randomPosition
      case randomScale
      case keepAspectRatio
      case flipHorizonal
      case flipVertical
      case doubleFlip
      case noiseLayer
      case backgroundsFolder
  }

  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    if let noBackground = try? values.decode(Bool.self, forKey: .noBackground) {
      self.noBackground = noBackground
    }
    if let everyBackground = try? values.decode(Bool.self, forKey: .everyBackground) {
      self.everyBackground = everyBackground
    }
    if let randomPosition = try? values.decode(Bool.self, forKey: .randomPosition) {
      self.randomPosition = randomPosition
    }
    if let randomScale = try? values.decode(Bool.self, forKey: .randomScale) {
      self.randomScale = randomScale
    }
    if let keepAspectRatio = try? values.decode(Bool.self, forKey: .keepAspectRatio) {
      self.keepAspectRatio = keepAspectRatio
    }
    if let flipHorizonal = try? values.decode(Bool.self, forKey: .flipHorizonal) {
      self.flipHorizonal = flipHorizonal
    }
    if let flipVertical = try? values.decode(Bool.self, forKey: .flipVertical) {
      self.flipVertical = flipVertical
    }
    if let doubleFlip = try? values.decode(Bool.self, forKey: .doubleFlip) {
      self.doubleFlip = doubleFlip
    }
    if let noiseLayer = try? values.decode(Bool.self, forKey: .noiseLayer) {
      self.noiseLayer = noiseLayer
    }
    if let backgroundsFolder = try? values.decode(URL.self, forKey: .backgroundsFolder) {
      self.backgroundsFolder = backgroundsFolder
    }
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(noBackground, forKey: .noBackground)
    try container.encode(everyBackground, forKey: .everyBackground)
    try container.encode(randomPosition, forKey: .randomPosition)
    try container.encode(randomScale, forKey: .randomScale)
    try container.encode(keepAspectRatio, forKey: .keepAspectRatio)
    try container.encode(flipHorizonal, forKey: .flipHorizonal)
    try container.encode(flipVertical, forKey: .flipVertical)
    try container.encode(doubleFlip, forKey: .doubleFlip)
    try container.encode(noiseLayer, forKey: .noiseLayer)
    try container.encode(backgroundsFolder, forKey: .backgroundsFolder)
  }

  var backgrounds: [URL] {
    guard let url = self.backgroundsFolder else {
      return []
    }
    let contents = try! FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles])
    return contents.filter { $0.path.lowercased().hasSuffix(".png") }
  }

  static var specimen: WorkspaceModel {
    WorkspaceModel()
  }
}
