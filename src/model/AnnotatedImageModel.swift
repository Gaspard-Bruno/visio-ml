import Combine

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

class AnnotatedImageModel: Codable {

  init(imagefilename: String, annotation: [LabelModel]) {
    self.imagefilename = imagefilename
    self.annotation = annotation
  }

  var imagefilename: String
  var annotation: [LabelModel]

  static var specimen: AnnotatedImageModel {
    AnnotatedImageModel(imagefilename: "cat-and-dog.png", annotation: [LabelModel.specimen])
  }
}
