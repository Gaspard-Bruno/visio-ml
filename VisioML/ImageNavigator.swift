import SwiftUI

struct ImageNavigator: View {

  @ObservedObject var appData = AppData.shared

  var body: some View {
    VStack {
      HStack(spacing: 0) {
        InspectorTab(label: "Input", inspector: "input", selection: .constant("none"))
        InspectorTab(label: "Output", inspector: "output", selection: .constant("none"))
      }
      .padding(.top, 8)
      .fixedSize()
      ScrollView {
        VStack(spacing: 0) {
          ForEach(appData.annotatedImages) {
            ImageRow(annotatedImage: $0)
          }
          Spacer()
        }
      }
      .frame(minWidth: 150, maxWidth: 250, maxHeight: .infinity)
    }
    .background(Color(NSColor.windowBackgroundColor))
    .background(KeyboardHandler())
    .transition(.asymmetric(insertion: .slide, removal: .move(edge: .leading)))

  }
}

struct ImageList_Previews: PreviewProvider {
  static var previews: some View {
    ImageNavigator()
  }
}
