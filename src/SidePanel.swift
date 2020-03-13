import SwiftUI

struct SidePanel: View {
  var body: some View {
    VStack {
      TabView {
        AnnotationInspector()
        .tag("annotation")
        .tabItem {
          Text("Annotation")
        }
      }
      Button("Export JSON") {
      
      }
      .padding()
    }
  }
}


struct SidePanel_Previews: PreviewProvider {
  static var previews: some View {
    SidePanel()
  }
}
