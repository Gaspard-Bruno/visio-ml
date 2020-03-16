import SwiftUI

struct AnnotationInspector: View {

  @EnvironmentObject var dataStore: DataStore

  var body: some View {
    ScrollView(.vertical) {
      VStack {
        TextField("Image name", text: $dataStore.annotatedImage.imagefilename)
        .padding()
        Divider()
        ForEach(dataStore.annotatedImage.annotation.indices, id: \.self) { i in
          LabelDetails(label: self.$dataStore.annotatedImage.annotation[i])
        }

//        ForEach(dataStore.annotatedImage.annotation) {
//          LabelDetails(label: $0)
//        }
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
