import Combine
import CoreGraphics

/*
// JSON file
[
 {
   "imagefilename": "cat and dog.png",
   "annotation":
   [
     {
       "label": "cat",
       "coordinates":
       {
         "y": 2.0,
         "x": 3.9,
         "height": 40.1,
         "width": 20.0
       }
     }, {
       "label": "dog",
       "coordinates":
       {
         "y": 40.0,
         "x": 38.9,
         "height": 100.1,
         "width": 70.0
       }
     }
   ]
 },
 ...
]
*/

class ImageAnnotationModel: Codable, Identifiable, Equatable, Hashable, ObservableObject {

  static func == (lhs: ImageAnnotationModel, rhs: ImageAnnotationModel) -> Bool {
    lhs.imagefilename == rhs.imagefilename
  }
  
  var id: String {
    imagefilename
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(imagefilename)
  }

  init(imagefilename: String, annotation: [LabelModel]) {
    self.imagefilename = imagefilename
    self.annotation = annotation
  }

  @Published var imagefilename: String
  @Published var annotation: [LabelModel]
  
  enum CodingKeys: String, CodingKey {
      case imagefilename
      case annotation
  }

  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    imagefilename = try values.decode(String.self, forKey: .imagefilename)
    annotation = try values.decode([LabelModel].self, forKey: .annotation)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(imagefilename, forKey: .imagefilename)
    try container.encode(annotation, forKey: .annotation)
  }

  static var specimen: ImageAnnotationModel {
    ImageAnnotationModel(imagefilename: "cat-and-dog.png", annotation: [LabelModel.specimen])
  }
}