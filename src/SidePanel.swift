import SwiftUI

struct SidePanel: View {

  @EnvironmentObject var dataStore: DataStore

  var body: some View {
    VStack {
      TabView {
        AnnotationInspector()
        .tag("annotation")
        .tabItem {
          Text("Annotation")
        }
        ImageInfo()
        .tag("imageinfo")
        .tabItem {
          Text("Image info")
        }
      }
    }
  }
}


struct SidePanel_Previews: PreviewProvider {
  static var previews: some View {
    SidePanel()
  }
}
