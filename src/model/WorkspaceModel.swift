import Combine
import Foundation

class WorkspaceModel: Codable, ObservableObject {

  init() { }

  @Published var flipHorizonal = false
  @Published var flipVertical = false
  @Published var backgrounds: [URL] = []

  enum CodingKeys: String, CodingKey {
      case flipHorizonal
      case flipVertical
      case backgrounds
  }

  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    flipHorizonal = try values.decode(Bool.self, forKey: .flipHorizonal)
    flipVertical = try values.decode(Bool.self, forKey: .flipVertical)
    backgrounds = try values.decode([URL].self, forKey: .backgrounds)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(flipHorizonal, forKey: .flipHorizonal)
    try container.encode(flipVertical, forKey: .flipVertical)
    try container.encode(backgrounds, forKey: .backgrounds)
  }

  static var specimen: WorkspaceModel {
    WorkspaceModel()
  }
}
