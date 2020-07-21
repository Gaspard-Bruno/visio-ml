import Foundation

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
struct AnnotatedImage {

  private enum CodingKeys: String, CodingKey {
    case imagefilename
    case annotation
  }

  var url: URL
  var annotations = [Annotation]()
  var isEnabled = true
  var isActive = false
  var isMarked = false
  
  var shortName: String {
    url.lastPathComponent
  }

  var hasActiveAnnotation: Bool {
    annotations.firstIndex { $0.isSelected } != nil
  }
  
  var activeAnnotation: Annotation {
    annotations.first { $0.isSelected }!
  }
  
  var fileExists: Bool {
    FileManager.default.fileExists(atPath: url.path)
  }

  mutating func addAnnotation(withCoordinates coordinates: CGRect) {
    // Find an available name
    var count = 0
    var label = ""
    repeat {
      count += 1
      label = "label_\(count)"
    } while (annotations.first(where: { $0.label == label }) != nil)
    let newAnnotation = Annotation(label: label, coordinates: coordinates)
    annotations.append(newAnnotation)
    toggle(annotation: newAnnotation)
  }
  
  mutating func toggle(annotation: Annotation) {
    annotations.indices.forEach { i in
      annotations[i].isSelected = annotations[i].id == annotation.id
    }
  }
  
  mutating func beginMoving(annotation: Annotation) {
    toggle(annotation: annotation)
    annotations.indices.forEach { i in
      annotations[i].isMoving = annotations[i].id == annotation.id
    }
  }

  mutating func move(annotation: Annotation, to newOrigin: CGPoint) {
    annotations.indices.forEach { i in
      annotations[i].isMoving = false
      if annotations[i].id == annotation.id {
        annotations[i].coordinates.origin = newOrigin
      }
    }
  }
  
  mutating func remove(annotation: Annotation) {
    annotations.removeAll { $0.id == annotation.id }
  }

  mutating func removeActiveAnnotation() {
    annotations.removeSelectedAnnotation()
  }

}

extension AnnotatedImage: Identifiable {
  var id: some Hashable {
    url
  }
}

extension AnnotatedImage: Codable {

  // Decodable
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let shortName = try values.decode(String.self, forKey: .imagefilename)
    url = AppData.shared.workingFolder!.appendingPathComponent(shortName)
    annotations = try values.decode([Annotation].self, forKey: .annotation)
  }

  // Encodable
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(shortName, forKey: .imagefilename)
    try container.encode(annotations, forKey: .annotation)
  }
}

extension Array where Element == AnnotatedImage {

  var marked: [AnnotatedImage] {
    filter { $0.isMarked }
  }

  mutating func removeActiveAnnotation() {
    guard
      let i = firstIndex(where: { $0.isActive } )
    else {
      return
    }
    self[i].removeActiveAnnotation()
  }
  
  mutating func activateNext(reverse: Bool = false) {
    guard let i = firstIndex(where: { $0.isActive } ) else {
      return
    }
    if (reverse && i > 0) || (!reverse && i < count - 1 ) {
      self[i].isActive.toggle()
      self[reverse ? i - 1 : i + 1].isActive.toggle()
    }
  }
}
