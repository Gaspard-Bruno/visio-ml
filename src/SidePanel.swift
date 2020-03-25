import SwiftUI

struct SidePanel: View {

  @EnvironmentObject var store: DataStore

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
        SyntheticsSettings()
        .tag("syntheticssettings")
        .tabItem {
          Text("Synthetics")
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
