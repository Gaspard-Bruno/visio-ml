import Combine
import Foundation

class WorkspaceModel: Codable, ObservableObject {

  init() { }

  @Published var flipHorizonal = true
  @Published var flipVertical = true

  @Published var randomBgPosition = true
  @Published var backgrounds: [URL] = []

  enum CodingKeys: String, CodingKey {
      case flipHorizonal
      case flipVertical
      case randomBgPosition
      case backgrounds
  }

  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    flipHorizonal = try values.decode(Bool.self, forKey: .flipHorizonal)
    flipVertical = try values.decode(Bool.self, forKey: .flipVertical)
    if let randomBgPosition = try? values.decode(Bool.self, forKey: .randomBgPosition) {
      self.randomBgPosition = randomBgPosition
    }
    if let backgrounds = try? values.decode([URL].self, forKey: .backgrounds) {
      self.backgrounds = backgrounds
    }
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(flipHorizonal, forKey: .flipHorizonal)
    try container.encode(flipVertical, forKey: .flipVertical)
    try container.encode(randomBgPosition, forKey: .randomBgPosition)
    try container.encode(backgrounds, forKey: .backgrounds)
  }

  func addBackground(_ url: URL) {
    if !backgrounds.contains(url) {
      backgrounds.append(url)
    }
  }

  func removeBackground(_ url: URL) {
    backgrounds.removeAll {
      $0 == url
    }
  }

  static var specimen: WorkspaceModel {
    WorkspaceModel()
  }
}
