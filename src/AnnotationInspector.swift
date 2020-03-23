import SwiftUI

struct AnnotationInspector: View {

  @EnvironmentObject var dataStore: DataStore

  var annotation: [LabelModel] {
    annotatedImage.annotation
  }

  var annotatedImage: AnnotatedImageModel {
    dataStore.selectedAnnotatedImage!
  }

  var inspector: some View {
    ScrollView(.vertical) {
      VStack {
        //TextField("Image name", text: $dataStore.annotatedImage.imagefilename)
        Text("\(dataStore.selectedImage!.filename)")
        .padding()
        Divider()
        ForEach(annotation) {
          LabelDetails(label: $0)
        }
      }
    }
  }
  var body: some View {
    Group {
      if dataStore.selectedImage == nil {
        Text("Please add/select an image.")
      } else {
        inspector
      }
    }
  }
}


struct AnnotationInspector_Previews: PreviewProvider {
  static var previews: some View {
    AnnotationInspector()
    .environmentObject(DataStore())
  }
}
