import Combine
import CoreGraphics

class LabelModel: Codable, Identifiable {
  init(label: String, coordinates: CoordinatesModel) {
    self.label = label
    self.coordinates = coordinates
  }

  var label: String
  var coordinates: CoordinatesModel
  
  var id: String {
    label
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
  class CoordinatesModel: Equatable, Codable {

    static func == (lhs: LabelModel.CoordinatesModel, rhs: LabelModel.CoordinatesModel) -> Bool {
      lhs.y == rhs.y && lhs.x == rhs.x && lhs.height == rhs.height && lhs.width == rhs.width
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
