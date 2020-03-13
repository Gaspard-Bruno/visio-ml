import SwiftUI

struct AnnotationInspector: View {

  @EnvironmentObject var dataStore: DataStore

  var body: some View {
    ScrollView(.vertical) {
      VStack {
        ForEach(dataStore.labels.indices, id: \.self) { i in
          LabelDetails(
            label: self.$dataStore.labels[i],
            index: i
          )
        }
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
