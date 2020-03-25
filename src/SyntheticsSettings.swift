import SwiftUI

struct SyntheticsSettings: View {

  @EnvironmentObject var store: DataStore
  @State var flipHorizontal = false
  @State var flipVertical = false

  var image: ImageModel! {
    store.selectedImage
  }

  var info: some View {
    VStack {
      Toggle("Flip horizontal", isOn: $flipHorizontal)
      Toggle("Flip vertical", isOn: $flipVertical)
    }
    .padding()
  }
  var inspector: some View {
    ScrollView(.vertical) {
      VStack {
        //TextField("Image name", text: $store.annotatedImage!.imagefilename)
        Text("\(store.selectedImage!.filename)")
        .padding()
        Divider()
        info
        Divider()
        Button("Generate now") {
          if self.flipVertical {
            self.store.flipVertically()
          }
          if self.flipHorizontal {
            self.store.flipHorizontally()
          }
        }
      }
    }
  }
  var body: some View {
    Group {
      if image == nil {
        Text("Please add/select an image.")
      } else {
        inspector
      }
    }
  }

}


struct SyntheticsSettings_Previews: PreviewProvider {
  static var previews: some View {
    SyntheticsSettings()
    .environmentObject(DataStore())
  }
}
