import SwiftUI

struct ImageNavigator: View {

  @ObservedObject var appData = AppData.shared
  @State var tab = "input"

  var body: some View {
    VStack {
      if appData.outFolder != nil {
        HStack(spacing: 0) {
          NavigatorTab(label: "Input", key: "input", selection: $tab)
          NavigatorTab(label: "Output", key: "output", selection: $tab)
        }
        .padding(.top, 8)
        .fixedSize()
      }
      if tab == "input" {
        ScrollView {
          VStack(spacing: 0) {
            ForEach(appData.annotatedImages) {
              ImageRow(annotatedImage: $0)
            }
            Spacer()
          }
        }
        .frame(minWidth: 150, maxWidth: 250, maxHeight: .infinity)
      } else {
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
    }
    .background(Color(NSColor.windowBackgroundColor))
    .background(KeyboardHandler())
    .transition(.asymmetric(insertion: .slide, removal: .move(edge: .leading)))

  }
}

struct NavigatorTab: View {

  let label: LocalizedStringKey
  let key: String
  @Binding var selection: String

  var body: some View {
    Text(label)
    .padding(.horizontal)
    .padding(.vertical, 8)
    .background(
      Color(NSColor.controlHighlightColor)
    )
    .foregroundColor(
      selection == key
      ? Color(NSColor.controlAccentColor)
      : Color(NSColor.controlTextColor)
    )
    .border(Color(NSColor.separatorColor), width: 1)
    .onTapGesture {
      self.selection = self.key
    }
  }
}

struct ImageList_Previews: PreviewProvider {
  static var previews: some View {
    ImageNavigator()
  }
}
