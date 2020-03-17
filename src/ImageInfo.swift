import SwiftUI

struct ImageInfo: View {

  @EnvironmentObject var dataStore: DataStore

  var image: ImageModel {
    dataStore.selectedImage
  }

  var info: some View {
    VStack(alignment: .leading) {
      Text("Actual width: \(image.size.width)")
      Text("Actual height: \(image.size.height)")
      Text("Aspect ratio: \(image.aspectRatio)")
      Text("Scaled width: \(image.currentScaledSize.width)")
      Text("Scaled height: \(image.currentScaledSize.height)")
      Text("Scale ratio: \(image.currentScale)")
    }
    .padding()
    .font(.system(.body, design: .monospaced))
  }
  var body: some View {
    ScrollView(.vertical) {
      VStack {
        //TextField("Image name", text: $dataStore.annotatedImage!.imagefilename)
        Text("\(dataStore.annotatedImage!.imagefilename)")
        .padding()
        Divider()
        info
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
