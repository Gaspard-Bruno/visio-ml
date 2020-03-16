import Combine
import CoreGraphics

class LabelModel: Codable, Identifiable, Equatable, Hashable, ObservableObject {

  static func == (lhs: LabelModel, rhs: LabelModel) -> Bool {
    lhs.label == rhs.label
  }

  var id: String {
    label
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(label)
  }
  
  init(label: String, coordinates: CoordinatesModel) {
    self.label = label
    self.coordinates = coordinates
  }

  @Published var label: String
  @Published var coordinates: CoordinatesModel

  enum CodingKeys: String, CodingKey {
      case label
      case coordinates
  }

  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    label = try values.decode(String.self, forKey: .label)
    coordinates = try values.decode(CoordinatesModel.self, forKey: .coordinates)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(label, forKey: .label)
    try container.encode(coordinates, forKey: .coordinates)
  }

  static var specimen: LabelModel {
    LabelModel(label: "cat", coordinates: CoordinatesModel.specimen)
  }

  static var specimens: [LabelModel] {
    [
      specimen,
      LabelModel(label: "dog", coordinates: CoordinatesModel.specimen)
    ]
  }
}


extension LabelModel {
  class CoordinatesModel: Equatable, Codable, Hashable, ObservableObject {

    static func == (lhs: LabelModel.CoordinatesModel, rhs: LabelModel.CoordinatesModel) -> Bool {
      lhs.y == rhs.y && lhs.x == rhs.x && lhs.height == rhs.height && lhs.width == rhs.width
    }
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(y)
      hasher.combine(x)
      hasher.combine(height)
      hasher.combine(width)
    }
    
    init(y: CGFloat, x: CGFloat, height: CGFloat, width: CGFloat) {
      self.y = y
      self.x = x
      self.height = height
      self.width = width
    }

    var y: CGFloat
    var x: CGFloat
    var height: CGFloat
    var width: CGFloat
    
    static var specimen: CoordinatesModel {
      CoordinatesModel(y: 10, x: 20, height: 30, width: 40)
    }
  }
}
