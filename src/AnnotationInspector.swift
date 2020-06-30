import SwiftUI

struct AnnotationInspector: View {

  @ObservedObject var store = DataStore.shared

  var annotation: [LabelModel] {
    annotatedImage.annotation
  }

  var annotatedImage: ImageAnnotationModel {
    store.selectedAnnotatedImage!
  }

  var inspector: some View {
    ScrollView(.vertical) {
      VStack {
        //TextField("Image name", text: $store.annotatedImage.imagefilename)
        Text("\(store.selectedImage!.filename)")
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
      if store.selectedImage == nil {
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
    .environmentObject(DataStore.shared)
  }
}
