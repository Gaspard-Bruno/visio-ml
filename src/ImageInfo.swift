import SwiftUI

struct ImageInfo: View {

  @EnvironmentObject var store: DataStore

  var image: ImageModel! {
    store.selectedImage
  }

  var viewportSize: CGSize! {
    store.viewportSize
  }

  var scaleFactor: CGFloat! {
    store.currentScaleFactor
  }

  var info: some View {
    VStack(alignment: .leading) {
      Text("Actual width: \(image.size.width, specifier: "%.2f")")
      Text("Actual height: \(image.size.height, specifier: "%.2f")")
      Text("Aspect ratio: \(image.aspectRatio, specifier: "%.3f")")
      if viewportSize != nil {
        Text("Scaled width: \(viewportSize.width, specifier: "%.2f")")
        Text("Scaled height: \(viewportSize.height, specifier: "%.2f")")
        Text("Scale factor: \(scaleFactor, specifier: "%.3f")")
      }
    }
    .padding()
    .font(.system(.body, design: .monospaced))
  }
  var inspector: some View {
    ScrollView(.vertical) {
      VStack {
        //TextField("Image name", text: $store.annotatedImage!.imagefilename)
        Text("\(store.selectedImage!.filename)")
        .padding()
        Divider()
        info
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


struct ImageInfo_Previews: PreviewProvider {
  static var previews: some View {
    ImageInfo()
    .environmentObject(DataStore())
  }
}
